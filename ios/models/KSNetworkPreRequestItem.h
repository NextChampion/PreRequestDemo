//
//  KSNetworkCacheItem.h
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/29.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^onRequestFinishedBlock)(BOOL success,id result, NSError *error);

@interface KSNetworkPreRequestItem : NSObject

@property (nonatomic, strong) NSString *key;// 唯一id
@property (nonatomic, assign) BOOL isPropressing; // 是否进行中
@property (nonatomic, assign) NSInteger ExpirationTime; // 数据过期时间
@property (nonatomic, strong) NSMutableArray<onRequestFinishedBlock> *callBacks;// 回调任务
@property (nonatomic, strong) id result; // 网络请求回来的结果
@property (nonatomic, assign) BOOL isError;
@property (nonatomic, assign) NSInteger errorCode;

@end

NS_ASSUME_NONNULL_END
