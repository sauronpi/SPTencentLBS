//
//  ViewController.m
//  TencentLBSTest
//
//  Created by mirantslu on 16/4/19.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "ViewController.h"
#import "BaseMapViewController.h"
#import <TencentLBS/TencentLBS.h>

#define ViewControllerTitle @"腾讯定位SDK"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *classNames;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) TencentLBSLocationManager *locationManager;
@end

@implementation ViewController
@synthesize titles     = _titles;
@synthesize classNames = _classNames;
@synthesize tableView  = _tableView;

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titles[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"TencentLBSKit";
            
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *mainCellIdentifier = @"mainCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.titles[indexPath.section][indexPath.row];
    cell.detailTextLabel.text = self.classNames[indexPath.section][indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *className = self.classNames[indexPath.section][indexPath.row];
    
    UIViewController *subViewController = [[NSClassFromString(className) alloc] init];
    
    subViewController.title = self.titles[indexPath.section][indexPath.row];
    
    [self.navigationController pushViewController:subViewController animated:YES];
}

#pragma mark - Initialization

- (void)initTitles {
    NSArray *locTitles = @[@"先设置用户隐私同意",
                           @"POI连续定位展示",
                           @"不带POI连续定位展示",
                           @"步骑行惯导（DR）示例"];
    self.titles = [NSArray arrayWithObjects:locTitles, nil];
}

- (void)initClassNames {
    NSArray *locClassNames = @[@"UserPrivacyViewContoller",
                               @"SerialLocationAloneViewController",
                               @"BaseTestSerialLocationController",
                               @"TencentLBSDRViewController"];
    self.classNames = [NSArray arrayWithObjects:locClassNames, nil];
}

- (void)initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - Life Cycle

- (instancetype)init {
    if ((self = [super init])) {
        self.title = ViewControllerTitle;
        [self initTitles];
        [self initClassNames];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setToolbarHidden:YES animated:animated];
}

@end
