//
//  BaseMapViewController.m
//  TencentLBSTest
//
//  Created by mirantslu on 16/3/30.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseMapViewController.h"

@implementation BaseMapViewController

#pragma mark - Initialization

- (void)initTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor       = [UIColor whiteColor];
    titleLabel.text            = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTitle:self.title];
}

@end