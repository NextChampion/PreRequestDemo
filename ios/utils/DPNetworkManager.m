//
//  DPNetworkManager.m
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/28.
//
//

#import "DPNetworkManager.h"
#import "KSConvert.h"
#import "KSNetworkPreRequestItem.h"
#import <CommonCrypto/CommonDigest.h>
#import <pthread.h>
#import "YYThreadSafeDictionary.h"

@interface DPNetworkManager ()

@property (nonatomic, strong) YYThreadSafeDictionary *preRequestDic;

@end

@implementation DPNetworkManager

+ (DPNetworkManager *)shareInstance {
    static DPNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (NSMutableDictionary *)preRequestDic {
  if (_preRequestDic == nil) {
    _preRequestDic = [[YYThreadSafeDictionary alloc] init];
  }
  return _preRequestDic;
}

- (void)prePost:(NSString *)urlString
         params:(NSDictionary * )params {
  // 生成key
  NSString *requestKey = [self requestKeyWithUrlString:urlString params:params];
  // 检查是否有缓存
  KSNetworkPreRequestItem *oldItem = [self itemForRequestKey:requestKey];
  // 如果有缓存对象 (比如手误,或者卡顿导致rn入口被连击,发起两个预请求),如果有缓存对象,这不处理后续的
  if (oldItem != nil && oldItem.isPropressing == YES) {
    return;
  }
  // 如果没有缓存信息,则创建预请求的缓存对象
  KSNetworkPreRequestItem *newItem = [[KSNetworkPreRequestItem alloc] init];
  newItem.key = requestKey;
  // 标记当前预请求开始
  newItem.isPropressing = YES;
  // 然后将预请求信息存起来
  [self.preRequestDic setValue:newItem forKey:requestKey];
  
  __weak typeof(self) weakSelf = self;
  // 然后发起网络请求请求数据
  [self requestPOST:urlString params:params success:^(id  _Nonnull result) {
    KSNetworkPreRequestItem *item = [weakSelf.preRequestDic objectForKey:requestKey];
      // 请求成功,标记预请求结束
    item.isPropressing = NO;
      // 检查是否有回调,如果有的话, 表明非预请求的请求已经发了 直接通过回调返回数据,不再存在缓存里
      if (item.callBacks.count > 0) {
        for (int i = 0; i < item.callBacks.count; i ++) {
          onRequestFinishedBlock callBack = item.callBacks[i];
          if (callBack != nil) {
            callBack(YES, result, nil);
          }
        }
        // 同时也清除本次预请求的缓存信息
        [weakSelf.preRequestDic setValue:nil forKey:requestKey];
        return;;
      }
    // 如果没有回调任务, 记录一下预请求的结果
    item.isError = NO;
    item.result = result;
    } fail:^(DPRequestStatu status) {
      KSNetworkPreRequestItem *item = [weakSelf.preRequestDic objectForKey:requestKey];
      // 请求失败,标记预请求结束
      item.isPropressing = NO;
      // 检查是否有回调,如果有的话 直接通过回调返回数据,不在存在缓存里
      if (item.callBacks.count > 0) {
        for (int i = 0; i < item.callBacks.count; i ++) {
          onRequestFinishedBlock callBack = item.callBacks[i];
          if (callBack != nil) {
            NSError *err = [NSError errorWithDomain:urlString code:status userInfo:nil];
            callBack(NO, nil, err);
          }
        }
        // 清除本次请求的缓存对象
        [weakSelf.preRequestDic setValue:nil forKey:requestKey];
        return;;
      }
      // 如果没有回调任务, 记录一下预请求的结果
      item.isError = YES;
      item.errorCode = status;
    }];
}


- (void)post:(NSString *)urlString
      params:(NSDictionary *)params
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject {
  // 对请求进行编码
  NSString *requestKey = [self requestKeyWithUrlString:urlString params:params];
  // 查询是否有当前请求的预请求
  KSNetworkPreRequestItem *preRequestItem = [self itemForRequestKey:requestKey];
  // 如果存在预请求
  if (preRequestItem != nil) {
    // 预请求是否正在进行中
    if (preRequestItem.isPropressing) {
      // 如果正在进行中,创建一个回调任务,添加到回调队列里
      onRequestFinishedBlock block = ^(BOOL success,id result, NSError *error){
        if (success) {
          resolve(result);
        } else {
          reject(@"no_events", @"There were no events", error);
        }
      };
      [preRequestItem.callBacks addObject:block];
      // 然后本次请求结束
      return;
    }
    // 如果预请求结束
    // 查看请求结果是否成功
    // 如果预请求失败,表明当前请求失败,本次也不处理,回调失败的结果
    if (preRequestItem.isError) {
      NSError *err = [NSError errorWithDomain:urlString code:preRequestItem.errorCode userInfo:nil];
      reject(@"no_events", @"There were no events", err);
      // 清除预请求缓存信息
      [self.preRequestDic setValue:nil forKey:requestKey];
      return;
    }
    // 如果预请求成功
    // 返回成功的结果
    resolve(preRequestItem.result);
    // 清除预请求缓存信息
    [self.preRequestDic setValue:nil forKey:requestKey];
    return;
  }
  
  // 如果不存在预请求, 发起普通请求
  [self requestPOST:urlString params:params success:^(id  _Nonnull result) {
      resolve(result);
    } fail:^(DPRequestStatu status) {
      reject(@"no_events", @"There were no events", nil);
    }];
}


- (NSString *)requestKeyWithUrlString: (NSString *)url
                               params: (NSDictionary *)params {
  NSString *jsonStr = [KSConvert dictionaryToJson:params];
  if (jsonStr == nil) {
    return  [self md5String:url] ;
  }
  NSString *urlAndParamsString =[url stringByAppendingString:jsonStr];
  return  [self md5String:urlAndParamsString];
}

- (KSNetworkPreRequestItem *)itemForRequestKey: (NSString *)key {
  if (key == nil) {
    return nil;
  }
  KSNetworkPreRequestItem *result = [self.preRequestDic valueForKey:key];
  return  result;
}


- (void)requestPOST:(nonnull NSString *)urlstring
             params:(nonnull NSDictionary *)params
            success:(responseSuccess)success
               fail:(responseFailure)fail {
    
    [self requestHttpMethod:DPHttpPOST
                  urlString:urlstring
                     params:params
                    success:^(id  _Nonnull result) {
        if (success) {
            success(result);
        }
    } fail:^(DPRequestStatu status) {
        if (fail) {
            fail(status);
        }
    }];
}
- (void)requestGET:(nonnull NSString *)urlstring
            params:(nonnull NSDictionary *)params
           success:(responseSuccess)success
              fail:(responseFailure)fail {
    
    [self requestHttpMethod:DPHTTPGET
                  urlString:urlstring
                     params:params
                    success:^(id  _Nonnull result) {
        if (success) {
            success(result);
        }
    } fail:^(DPRequestStatu status) {
        if (fail) {
            fail(status);
        }
    }];
    
}
- (void)requestHttpMethod:(DPHTTPMethod)method
                urlString:(nonnull NSString *)urlstring
                   params:(nonnull NSDictionary *)params
                  success:(nonnull responseSuccess)success
                     fail:(nonnull responseFailure)fail {
    
    NSString *paramsString = [self dictParamsToString:params];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
    request.HTTPMethod = [self httpMethod:method];
    request.timeoutInterval = 10;
    request.HTTPBody = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       
        if (error) {
            if (fail) {
                fail(DPRequestFailure);
            }
        } else {
            if (success) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                success(dict);
            }
        }
        
    }];
    [dataTask resume];
}

- (NSString *)dictParamsToString:(NSDictionary *)params {
    NSMutableString *paramsString = [[NSMutableString alloc] initWithCapacity:0];
       for (int i = 0;i < [params allKeys].count;i++) {
           NSString *key = [[params allKeys] objectAtIndex:i];
           [paramsString appendString:[NSString stringWithFormat:@"%@=%@",key,[params objectForKey:key]]];
           if (i < [params allKeys].count-1) {
               [paramsString appendString:@"&"];
           }
       }
    return paramsString.copy;
}

- (NSString *)httpMethod:(DPHTTPMethod)method {
    return method == DPHTTPGET ? @"GET":@"POST";
}


- ( NSString *)md5String:( NSString *)str {
    
    const char *myPasswd = [str UTF8String ];
    
    unsigned char mdc[ 16 ];
    
    CC_MD5 (myPasswd, ( CC_LONG ) strlen (myPasswd), mdc);
    
    NSMutableString *md5String = [ NSMutableString string ];
    
    for ( int i = 0 ; i< 16 ; i++) {
        
        [md5String appendFormat : @"%02x" ,mdc[i]];
        
    }
    
    return md5String;
}
@end
