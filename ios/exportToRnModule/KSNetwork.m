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
  [kNetwork prePost:urlString params:params];
}

// promise
RCT_REMAP_METHOD(post,postWithUrl:(NSString *)urlString params:(NSDictionary *)params resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [kNetwork post:urlString params:params resolver:resolve rejecter:reject];
}






@end
