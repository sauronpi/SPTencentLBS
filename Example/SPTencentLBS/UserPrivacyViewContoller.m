//
//  UserPrivacyViewContoller.m
//  TencentLBSTest
//
//  Created by Ranyruan on 2022/4/7.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "UserPrivacyViewContoller.h"

#import <TencentLBS/TencentLBS.h>

@interface UserPrivacyViewContoller ()<TencentLBSLocationManagerDelegate>

@property (readwrite, nonatomic, strong) TencentLBSLocationManager *locationManager;

@property (readwrite, nonatomic, strong) UILabel *displayLabel;

@property (readwrite, nonatomic, strong) dispatch_source_t timer;

@end

@implementation UserPrivacyViewContoller

#pragma mark - Action Handle

- (void)configLocationManager {
    
    self.locationManager = [[TencentLBSLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setRequestLevel:TencentLBSRequestLevelAdminName];
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

- (void)stopUpdatingLocation{
    [self.locationManager stopUpdatingLocation];
}
#pragma mark - TencentLBSLocationManagerDelegate

- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager
                 didFailWithError:(NSError *)error {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"定位权限未开启，是否开启？" preferredStyle:  UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]] ) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:nil completionHandler:^(BOOL success) {
//
//            }]
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
    
    [self.displayLabel setText:[NSString stringWithFormat:@"version:%@\n%@\n %@\n latitude:%f, longitude:%f\n horizontalAccuracy:%f \n verticalAccuracy:%f\n speed:%f\n course:%f\n altitude:%f\n nationcode:%ld\ntimestamp:%@\n",[TencentLBSLocationManager getLBSSDKVersion], location.name, location.address, location.location.coordinate.latitude, location.location.coordinate.longitude, location.location.horizontalAccuracy, location.location.verticalAccuracy, location.location.speed, location.location.course, location.location.altitude, location.nationCode, dateString]];
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

    [self stopUpdatingLocation];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertMessage:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 用户同意隐私政策之后，再初始化定位，否则定位将不可用(定位隐私政策参考：https://privacy.qq.com/document/preview/dbd484ce652c486cb6d7e43ef12cefb0)
        [TencentLBSLocationManager setUserAgreePrivacy:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configLocationManager];
            [self startUpdatingLocation];
        });
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [TencentLBSLocationManager setUserAgreePrivacy:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.displayLabel setText:@"用户未同意隐私政策，定位不可用"];
        });
    }];

    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initBaseNavigationBar];
    [self initDisplayLabel];
    [self alertMessage:@"是否同意腾讯定位SDK隐私政策"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.translucent = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
}

@end
