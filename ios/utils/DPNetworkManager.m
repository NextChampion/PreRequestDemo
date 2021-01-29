//
//  DPNetworkManager.m
//  Task2
//
//  Created by hzw on 2020/7/31.
//  Copyright © 2020 BHB. All rights reserved.
//

#import "DPNetworkManager.h"

@implementation DPNetworkManager

+ (DPNetworkManager *)shareInstance {
    static DPNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
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
@end
