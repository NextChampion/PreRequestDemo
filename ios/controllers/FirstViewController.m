//
//  FirstViewController.m
//  PreRequestDemo
//
//  Created by zhangcunxia on 2021/1/28.
//

#import "FirstViewController.h"
#import "RNViewController.h"
#import "KSDate.h"
#import "DPNetworkManager.h"

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
  NSString *ts = [NSString stringWithFormat:@"%f",  CFAbsoluteTimeGetCurrent()];
  RNViewController *rnVC = [[RNViewController alloc] init];
  rnVC.clickTime = ts;
  NSString *urlString = [NSString stringWithFormat:@"http://v.juhe.cn/toutiao/index?type=top&key=b6a70a0df051ea3e4b7e62f90e17e1a3"];
  [kNetwork prePost:urlString params:nil];
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
