//
//  BaseTestSerialLocationController.m
//  TencentLBSTest
//
//  Created by mirantslu on 16/5/4.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "BaseTestSerialLocationController.h"
#import <TencentLBS/TencentLBS.h>

@interface BaseTestSerialLocationController ()<TencentLBSLocationManagerDelegate>

@property (readwrite, nonatomic, strong) TencentLBSLocationManager *locationManager;

@property (readwrite, nonatomic, strong) UILabel *displayLabel;

@end

@implementation BaseTestSerialLocationController

#pragma mark - Action Handle

- (void)configLocationManager {
    self.locationManager = [[TencentLBSLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    [self.locationManager setApiKey:@"WZCBZ-OLPCU-TJJVJ-4LZTE-SSG5O-6JFEM"];//您申请的key
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)startUpdatingLocation {
    [self.locationManager startUpdatingLocation];
}

#pragma mark - TencentLBSLocationManagerDelegate

- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                 didFailWithError:(NSError *)error {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"定位权限未开启，是否开启？" preferredStyle:  UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if( [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]] ) {
#if  __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{}completionHandler:^(BOOL success) {
                }];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
#endif
            }
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self presentViewController:alert animated:true completion:nil];
        
    } else {
        [self.displayLabel setText:[NSString stringWithFormat:@"%@", error]];
    }
}

- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                didUpdateLocation:(TencentLBSLocation *)location {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *dateString = [fmt stringFromDate:location.location.timestamp];
    
    [self.displayLabel setText:[NSString stringWithFormat:@" version:%@\n latitude:%f, longitude:%f\n horizontalAccuracy:%f \n verticalAccuracy:%f\n speed:%f\n course:%f\n altitude:%f\n timestamp:%@",[TencentLBSLocationManager getLBSSDKVersion],location.location.coordinate.latitude, location.location.coordinate.longitude, location.location.horizontalAccuracy, location.location.verticalAccuracy, location.location.speed, location.location.course, location.location.altitude, dateString]];
}

#pragma mark - Initialization

- (void)initBaseNavigationBar {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
}

- (void)initDisplayLabel {
    _displayLabel = [[UILabel alloc] init];
    _displayLabel.backgroundColor = [UIColor clearColor];
    _displayLabel.textColor = [UIColor blackColor];
    _displayLabel.textAlignment = NSTextAlignmentCenter;
    _displayLabel.numberOfLines = 0;
    [_displayLabel setFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_displayLabel];
}

- (void)returnAction {
    [self.locationManager stopUpdatingLocation];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initBaseNavigationBar];
    [self initDisplayLabel];
    if (![TencentLBSLocationManager getUserAgreePrivacy]) {
        [self.displayLabel setText:@"用户还未同意隐私政策，定位将不可用"];
        return;
    }
    [self configLocationManager];
    [self startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.translucent = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
}

@end
