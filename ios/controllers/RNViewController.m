//
//  RNViewController.m
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/28.
//

#import "RNViewController.h"
#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "AppDelegate.h"

@interface RNViewController ()

@end

@implementation RNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initRn];
}

- (void)initRn {
  AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
  NSLog(@"rn页面拿到的点击按钮的时间：%@",self.clickTime);
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:app.bridge
                                                   moduleName:@"PreRequestDemo"
                                            initialProperties:nil];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  self.view = rootView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
