//
//  KSAbsoluteTimeManager.m
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/29.
//

#import "KSAbsoluteTimeManager.h"
#import <React/RCTLog.h>
@implementation KSAbsoluteTimeManager

RCT_EXPORT_MODULE();

// 无返回值普通方法
RCT_EXPORT_METHOD(logCurrentTimeWithDesc:(NSString *)descString)
{
  NSString *ts = [NSString stringWithFormat:@"%f",  CFAbsoluteTimeGetCurrent()];
  RCTLogInfo(@"%@ at %@", descString, ts);
}



@end
