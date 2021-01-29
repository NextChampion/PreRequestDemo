//
//  DPNetworkManager.h
//  Task2
//
//  Created by hzw on 2020/7/31.
//  Copyright © 2020 BHB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kNetwork [DPNetworkManager shareInstance]

///网络请求响应结果
typedef enum : NSUInteger {
    DPRequestSuccess,//200
    DPRequestFailure,//40x
    DPRequestServiceError,//50x
    DPRequestUnknow//30x
} DPRequestStatu;

///网络请求方式
typedef enum : NSUInteger {
    DPHttpPOST,
    DPHTTPGET,
} DPHTTPMethod;

///网络请求成功结果回调
typedef void (^responseSuccess)(id result);

///网络请求失败结果回调
typedef void (^responseFailure)(DPRequestStatu status);

@interface DPNetworkManager : NSObject

+ (DPNetworkManager *)shareInstance;

/// POST请求方法
/// @param urlstring 接口地址
/// @param params 请求参数
/// @param success 成功回调
/// @param fail 失败回调
- (void)requestPOST:(nonnull NSString *)urlstring
             params:(nonnull NSDictionary *)params
            success:(responseSuccess)success
               fail:(responseFailure)fail;


/// GET请求方法
/// @param urlstring 接口地址
/// @param params 请求参数
/// @param success 成功回调
/// @param fail 失败回调
- (void)requestGET:(nonnull NSString *)urlstring
            params:(nonnull NSDictionary *)params
           success:(responseSuccess)success
              fail:(responseFailure)fail;
@end

NS_ASSUME_NONNULL_END
