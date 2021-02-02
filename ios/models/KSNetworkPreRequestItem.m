//
//  KSNetworkCacheItem.m
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/29.
//

#import "KSNetworkPreRequestItem.h"

@implementation KSNetworkPreRequestItem

- (NSMutableArray<onRequestFinishedBlock> *)callBacks {
  if (_callBacks == nil) {
    _callBacks = [[NSMutableArray alloc] init];
  }
  return  _callBacks;
}

@end
