//
//  MEKSearchViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKSearchViewController.h"
#import "MEKVideoPlayerViewController.h"
#import <Masonry/Masonry.h>
#import "AppDelegate.h"

@interface MEKSearchViewController () <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation MEKSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    UIView *superview = self.view;
    
    self.searchTextField = [UITextField new];
    self.searchTextField.placeholder = @"YouTube URL";
    self.searchTextField.textAlignment = NSTextAlignmentCenter;
    self.searchTextField.textColor = UIColor.blueColor;
    self.searchTextField.delegate = self;
    //self.searchTextField.backgroundColor = UIColor.grayColor;
    [self.view addSubview:self.searchTextField];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.searchButton setTitle:@"GO" forState:UIControlStateNormal];
    self.searchButton.tintColor = UIColor.whiteColor;
    self.searchButton.backgroundColor = UIColor.redColor;
    [self.searchButton addTarget:self action:@selector(goButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.searchButton.layer.cornerRadius = 10;
    self.searchButton.layer.masksToBounds = YES;
    [self.view addSubview:self.searchButton];
    
    //UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(superview.mas_centerY).with.offset(-50);
        make.centerX.equalTo(superview.mas_centerX).with.offset(0);
        make.width.equalTo(superview.mas_width);
        make.height.equalTo(@50);
    }];
    
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superview.mas_centerX).with.offset(0);
        make.top.equalTo(self.searchTextField.mas_bottom).with.offset(20);
        make.width.equalTo(@200);
        make.height.equalTo(@50);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.view addGestureRecognizer:tap];
}

- (void)goButtonTapped: (UIButton*) button
{
    [self.view endEditing:YES];
    
//    self.view.layer.masksToBounds = YES;
//    
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    //UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    blurEffectView.alpha = 0;
//    //always fill the view
//    blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
//    blurEffectView.frame = self.view.bounds;
//    //blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    //[self.view insertSubview:blurEffectView atIndex:0];
//    //[self.view addSubview:blurEffectView];
 
    AppDelegate *appDelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.player openPlayer];
}


//
//// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
//- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
//
//    // bail if the current state matches the desired state
//    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
//
//    // get a frame calculation ready
//    CGRect frame = self.tabBarController.tabBar.frame;
//    CGFloat height = frame.size.height;
//    CGFloat offsetY = (visible)? -height : height;
//
//    // zero duration means no animation
//    CGFloat duration = (animated)? 0.5 : 0.0;
//
//    [UIView animateWithDuration:duration animations:^{
//        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
//    } completion:completion];
//}
//
////Getter to know the current state
//- (BOOL)tabBarIsVisible {
//    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
//}

- (void)backgroundTapped
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
