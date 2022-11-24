//
//  TencentLBSDRViewController.m
//  TencentLBSTest
//
//  Created by fengli ruan on 2021/12/22.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TencentLBSDRViewController.h"
#import <TencentLBS/TencentLBS.h>

static dispatch_queue_t tencentDr_timer_get_queue() {
    static dispatch_queue_t tencentlbs_tencentDr_timer_get_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tencentlbs_tencentDr_timer_get_queue = dispatch_queue_create("com.tencent.lbs.dr.timer", DISPATCH_QUEUE_SERIAL);
    });
    return tencentlbs_tencentDr_timer_get_queue;
}

@interface TencentLBSDRViewController ()<TencentLBSLocationManagerDelegate>

@property (readwrite, nonatomic, strong) TencentLBSLocationManager *locationManager;

@property (readwrite, nonatomic, strong) UILabel *displayLabel;

@property (readwrite, nonatomic, strong) dispatch_source_t timer;

@end

@implementation TencentLBSDRViewController

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

- (void)startTencentDrEngine{
    if ([self.locationManager isSupport]) {
        TencentLBSDRStartCode startCode = [self.locationManager startDrEngine:TencentLBSDRStartMotionTypeWalk];
        if (startCode == TencentLBSDRStartCodeSuccess) {
            NSLog(@"步骑行惯导启动成功，然后可通过getPosition获取结果");
        }
    }
}

- (void)startTimer{
    self.timer = [self createDispatchTimerWithInterval:1.0f];
}

- (void)stopTimer{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)timerEventHandler{
    TencentLBSLocation *drLocation = [self.locationManager getPosition];
    NSLog(@"drLocation:%@",drLocation);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.displayLabel setText:[NSString stringWithFormat:@"version:%@\n %@",[TencentLBSLocationManager getLBSSDKVersion],drLocation]];
    });
}

- (dispatch_source_t)createDispatchTimerWithInterval:(NSTimeInterval)interval {
    int leeway = 1;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, tencentDr_timer_get_queue());
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, leeway * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self timerEventHandler];
    });
    dispatch_resume(timer);
    
    return timer;
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
    [self.locationManager terminateDrEngine];
    [self stopTimer];
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

    //若获取的drLocatin中带有地址信息，可
    [self.locationManager setRequestLevel:TencentLBSRequestLevelAdminName];
    [self startUpdatingLocation];
    
    //启动dr，确保有定位权限
    [self startTencentDrEngine];
    [self startTimer];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.translucent = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
}

@end
