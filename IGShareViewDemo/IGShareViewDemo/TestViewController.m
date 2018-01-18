//
//  TestViewController.m
//  IGShareViewDemo
//
//  Created by Kennith.Zeng on 2018/1/18.
//  Copyright © 2018年 Kennith.Zeng. All rights reserved.
//

#import "TestViewController.h"
#import "IGCusShareView.h"
@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-200)/2, 80, 200, 45)];
    [btn setTitle:@"展示" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showShareView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showShareView{
    IGCusShareView *view = [[IGCusShareView alloc] initWithFrame:self.view.bounds];
    [view showFromControlle:self];
}

@end
