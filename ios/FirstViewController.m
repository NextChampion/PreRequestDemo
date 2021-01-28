//
//  FirstViewController.m
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/28.
//

#import "FirstViewController.h"
#import "RNViewController.h"
#import "KSDate.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    // Do any additional setup after loading the view.
}

- (void)setUp {
  self.view.backgroundColor = [UIColor whiteColor];
  UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 300, 50)];
  [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
  [button setTitle:@"跳转到rn页面" forState:UIControlStateNormal];
  
  [button addTarget:self action:@selector(jumpToRnScreen) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
}

- (void)jumpToRnScreen {
  NSLog(@"跳转到rn");
  NSString *ts = [KSDate getNowTimeTimestamp3];
  NSLog(@"点击按钮的时间：%@",ts);
  RNViewController *rnVC = [[RNViewController alloc] init];
  rnVC.clickTime = ts;
  [self.navigationController pushViewController:rnVC animated:YES];
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
