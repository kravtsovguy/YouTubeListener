//
//  MEKSearchViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKSearchViewController.h"
#import "ViewController.h"
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
//    
//    UIView *darkView = [[UIView alloc] initWithFrame:self.view.frame];
//    darkView.backgroundColor = UIColor.blackColor;
//    darkView.translatesAutoresizingMaskIntoConstraints = NO;
//    darkView.alpha = 0;
//    [self.view addSubview:darkView];
//    
//    
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
//        //self.view.layer.backgroundColor = UIColor.blackColor.CGColor;
//        darkView.alpha = 0.5;
//        self.view.layer.cornerRadius = 10;
//        //self.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
//        self.view.superview.layer.sublayerTransform = CATransform3DMakeScale(0.9, 0.9, 1.0);
//        //self.view.layer.sublayerTransform = CATransform3DMakeScale(0.9, 0.9, 1.0);
//    } completion:nil];
//    
    AppDelegate *appDelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openVideoController];
    
    return;
    
    //===============
//    ViewController *vc = [ViewController new];
//    
//    [self addChildViewController:vc];
//    [vc.view setFrame:CGRectMake(5, 0, self.view.frame.size.width - 10, self.view.frame.size.height)];
//    vc.view.layer.cornerRadius = 20;
//    vc.view.layer.masksToBounds = YES;
//    [self.view addSubview:vc.view];
//    [vc didMoveToParentViewController:self];
//    
//    CGFloat size = 400;
//    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
//    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - size - tabBarHeight, CGRectGetWidth(self.view.frame), size)];
//    //sv.backgroundColor = UIColor.grayColor;
//    sv.showsVerticalScrollIndicator = NO;
//    sv.contentSize = CGSizeMake(self.view.frame.size.width, size + 1);//self.view.frame.size.height * 1.1);
//    sv.clipsToBounds = NO;
//    sv.delegate = self;
//    //sv.scrollEnabled = YES;
//    //sv.bounces = NO;
//    //[sv setContentOffset:CGPointZero animated:YES];
//    [sv addSubview:vc.view];
//    [self.view addSubview:sv];
//    
//    [sv setContentOffset:CGPointMake(0, -CGRectGetHeight(sv.frame)) animated:NO];
//    CGFloat pageWidth  = sv.frame.size.width;
//    CGFloat pageHeight = sv.frame.size.height;
//    CGRect rect = CGRectMake(0, 0, pageWidth, pageHeight);
//    [sv scrollRectToVisible:rect animated:YES];
//    
//    
//    //===================
    
//    [UIView animateWithDuration:1.0 animations: ^{
//        self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.tabBarController.tabBar.bounds));
//    }];
    
    
//
//    [UIView animateWithDuration:1.0 animations: ^{
//        sv.transform = CGAffineTransformMakeTranslation(0, 200);
//        sv.frame = CGRectMake(sv.frame.origin.x - 5, sv.frame.origin.y, sv.frame.size.width + 10,  sv.frame.size.height - 200);
//    }];
//
    
    
    //[self.tabBarController.tabBar setHidden:YES];
    //[self setTabBarVisible:NO animated:YES completion:nil];
//    // Delay execution of my block for 10 seconds.
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [sv setContentOffset:CGPointZero animated:YES];
//    });
//
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 100)
    {
        [scrollView setContentOffset:CGPointMake(0, 100) animated:NO];
        
        CGFloat pageWidth  = scrollView.frame.size.width;
        CGFloat pageHeight = scrollView.frame.size.height;
        CGRect rect = CGRectMake(0, 0, pageWidth, pageHeight);
        [scrollView scrollRectToVisible:rect animated:YES];
    }
    
    NSLog(@"contentOffset: %f", scrollView.contentOffset.y);
    
    if (scrollView.contentOffset.y < -80)
    {
        NSLog(@"DOWN");
    }
}

// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.5 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

//Getter to know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

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
