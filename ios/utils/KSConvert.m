//
//  KSConvert.m
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/29.
//

#import "KSConvert.h"

@implementation KSConvert


+ (NSString *)dictionaryToJson:(NSDictionary *)dic {
  if (dic == nil) {
    return nil;
  }
 
  NSError *parseError = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
  return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];


}

@end
