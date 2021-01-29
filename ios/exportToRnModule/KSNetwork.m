//
//  KSNetwork.m
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/28.
//

#import "KSNetwork.h"
#import <React/RCTLog.h>
#import <AFNetworking.h>
#import "DPNetworkManager.h"
#import "KSConvert.h"
#import "KSNetworkCacheItem.h"

@interface KSNetwork ()

@property (nonatomic, strong) NSDictionary *cache;

@end

@implementation KSNetwork

- (NSDictionary *)cache {
  if (_cache == nil) {
    _cache = [NSDictionary dictionary];
  }
  return _cache;
}

RCT_EXPORT_MODULE();

// 无返回值普通方法
RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
  RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}


RCT_EXPORT_METHOD(addEventWithTime:(NSString *)name location:(NSString *)location date:(nonnull NSNumber *)secondsSinceUnixEpoch)
{
  NSLog(@"addEvent name=%@ location= %@ data=%@", name, location, secondsSinceUnixEpoch);
}

// 回调函数
RCT_EXPORT_METHOD(findEvents:(RCTResponseSenderBlock)callback)
{
  NSArray *events = @[@"111", @"2222", @"3333"];
  callback(@[[NSNull null], events]);
}

// promise
RCT_REMAP_METHOD(findEventsAsync,
                 findEventsWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  NSArray *events =  @[@"111", @"2222", @"3333", @"444"];
  if (events) {
    resolve(events);
  } else {
    NSError *error =  nil;
    reject(@"no_events", @"There were no events", error);
  }
}

RCT_EXPORT_METHOD(prePost:(NSString *)urlString params:(NSDictionary *)params)
{
  // 生成key
  NSString *requestKey = [self stringByUrl:urlString AndParams:params];
  // 检查是否有缓存
  KSNetworkCacheItem *oldCache = [self resultForRequestKey:requestKey];
  // 如果有缓存对象 (比如手误,或者卡顿导致rn入口被连击,发起两个预请求),如果有缓存对象,这不处理后续的
  if (oldCache != nil) {
    return;
  }
  // 如果没有缓存信息,则创建预请求的缓存对象
  KSNetworkCacheItem *newCache = [[KSNetworkCacheItem alloc] init];
  newCache.key = requestKey;
  // 标记当前预请求开始
  newCache.isPropressing = true;
  // 然后将预请求信息存起来
  [self.cache setValue:newCache forKey:requestKey];
  
  __weak typeof(self) weakSelf = self;
  // 然后发起网络请求请求数据
  [kNetwork requestPOST:urlString params:params success:^(id  _Nonnull result) {
      // 请求成功,标记预请求结束
      newCache.isPropressing = false;
      // 检查是否有回调,如果有的话, 表明非预请求的请求已经发了 直接通过回调返回数据,不再存在缓存里
      if (newCache.callBacks.count > 0) {
        for (int i = 0; i < newCache.callBacks.count; i ++) {
          onRequestFinishedBlock callBack = newCache.callBacks[i];
          if (callBack != nil) {
            callBack(true, result, nil);
          }
        }
        // 同时也清除本次预请求的缓存信息
        [weakSelf.cache setValue:nil forKey:requestKey];
        return;;
      }
    // 如果没有回调任务, 记录一下预请求的结果
      newCache.isError = false;
      newCache.result = result;
    } fail:^(DPRequestStatu status) {
      // 请求失败,标记预请求结束
      newCache.isPropressing = false;
      // 检查是否有回调,如果有的话 直接通过回调返回数据,不在存在缓存里
      if (newCache.callBacks.count > 0) {
        for (int i = 0; i < newCache.callBacks.count; i ++) {
          onRequestFinishedBlock callBack = newCache.callBacks[i];
          if (callBack != nil) {
            NSError *err = [NSError errorWithDomain:urlString code:status userInfo:nil];
            callBack(false, nil, err);
          }
        }
        // 清楚本次请求的缓存对象
        [weakSelf.cache setValue:nil forKey:requestKey];
        return;;
      }
      // 如果没有回调任务, 记录一下预请求的结果
      newCache.isError = true;
      newCache.errorCode = status;
    }];
}

// promise
RCT_REMAP_METHOD(post,postWithUrl:(NSString *)urlString params:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  // 对请求进行编码
  NSString *requestKey = [self stringByUrl:urlString AndParams:params];
  // 查询是否有当前请求的预请求
  KSNetworkCacheItem *cache = [self resultForRequestKey:requestKey];
  // 如果存在预请求
  if (cache != nil) {
    // 预请求是否正在进行中
    if (cache.isPropressing) {
      // 如果正在进行中,创建一个回调任务,添加到回调队列里
      onRequestFinishedBlock block = ^(BOOL success,id result, NSError *error){
        if (success) {
          resolve(result);
        } else {
          reject(@"no_events", @"There were no events", error);
        }
      };
      [cache.callBacks addObject:block];
      // 然后本次请求结束
      return;
    }
    // 如果预请求结束
    // 查看请求结果是否成功
    // 如果预请求失败,表明当前请求失败,本次也不处理,回调失败的结果
    if (cache.isError) {
      NSError *err = [NSError errorWithDomain:urlString code:cache.errorCode userInfo:nil];
      reject(@"no_events", @"There were no events", err);
      // 清除预请求缓存信息
      [self.cache setValue:nil forKey:requestKey];
      return;
    }
    // 如果预请求成功
    // 返回成功的结果
    resolve(cache.result);
    // 清除预请求缓存信息
    [self.cache setValue:nil forKey:requestKey];
    return;
  }
  
  // 如果不存在预请求, 发起普通请求
  [kNetwork requestPOST:urlString params:params success:^(id  _Nonnull result) {
      resolve(result);
    } fail:^(DPRequestStatu status) {
      reject(@"no_events", @"There were no events", nil);
    }];
}

- (NSString *)stringByUrl:(NSString *)url AndParams: (NSDictionary *)params {
  NSString *jsonStr = [KSConvert dictionaryToJson:params];
  if (jsonStr == nil) {
    return  url;
  }
  return  [url stringByAppendingString:jsonStr];
}

- (KSNetworkCacheItem *)resultForRequestKey: (NSString *)key {
  if (key == nil) {
    return nil;
  }
  KSNetworkCacheItem *result = [self.cache valueForKey:key];
  return  result;
}



@end
