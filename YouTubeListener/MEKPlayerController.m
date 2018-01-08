//
//  MEKPlayerController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 06/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlayerController.h"
#import "MEKVideoPlayerViewController.h"
#import "AppDelegate.h"


static const CGFloat MEKPlayerViewSize = 320;

@interface MEKPlayerController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *darkView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MEKVideoPlayerViewController *playerViewController;

- (UITabBarController*)tabBarController;

@end

@implementation MEKPlayerController

-(UITabBarController *)tabBarController
{
    return ((AppDelegate*)[UIApplication sharedApplication].delegate).tabBarController;
}

-(void)openPlayer
{
    CGRect frame = self.tabBarController.view.frame;
    
    UIView *view = self.tabBarController.view.subviews[0];
    
    if (!self.playerViewController)
    {
        view.layer.masksToBounds = YES;
        
        UIView *darkView = [[UIView alloc] initWithFrame:frame];
        self.darkView = darkView;
        
        darkView.backgroundColor = UIColor.blackColor;
        darkView.alpha = 0;
        //darkView.translatesAutoresizingMaskIntoConstraints = NO;
        darkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:darkView];
    }
    //view.frame = CGRectOffset(view.frame, 50, 50);
    
    [view setNeedsUpdateConstraints];
    //[view updateConstraintsIfNeeded];
    
    //view.layer.anchorPoint = CGPointMake(0, 0);
    //darkView.layer.anchorPoint = CGPointMake(0, 0);
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        //self.view.layer.backgroundColor = UIColor.blackColor.CGColor;
        self.darkView.alpha = 0.5;
        view.layer.cornerRadius = 10;
        self.playerViewController.view.layer.cornerRadius = 10;
        
        self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.tabBarController.tabBar.frame));
        
        view.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1.0);
        
        //view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
        //view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        //self.view.superview.layer.sublayerTransform = CATransform3DMakeScale(0.9, 0.9, 1.0);
        //self.view.layer.sublayerTransform = CATransform3DMakeScale(0.9, 0.9, 1.0);
    } completion:nil];
    
    if (!self.playerViewController)
    {
        MEKVideoPlayerViewController *vc = [MEKVideoPlayerViewController new];
        self.playerViewController = vc;
        
        [self.tabBarController addChildViewController:vc];
        [vc.view setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        vc.view.layer.cornerRadius = 10;
        vc.view.layer.masksToBounds = YES;
        //[self.tabBarController.view addSubview:vc.view];
        [vc didMoveToParentViewController:self.tabBarController];
        
        //CGFloat size = 400;
        //CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
        UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), MEKPlayerViewSize)];
        self.scrollView = sv;
        
        //sv.backgroundColor = UIColor.grayColor;
        sv.showsVerticalScrollIndicator = NO;
        sv.contentSize = CGSizeMake(CGRectGetWidth(frame), MEKPlayerViewSize + 1);//self.view.frame.size.height * 1.1);
        sv.clipsToBounds = NO;
        sv.delegate = self;
        //sv.scrollEnabled = YES;
        //sv.bounces = NO;
        //[sv setContentOffset:CGPointZero animated:YES];
        [sv addSubview:vc.view];
        
        [self.tabBarController.view insertSubview:sv atIndex:1];
        //[self.tabBarController.view.subviews[0] addSubview:sv];
    }
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        //self.view.layer.backgroundColor = UIColor.blackColor.CGColor;
        //self.scrollView.frame = CGRectMake(0, CGRectGetHeight(frame) -  MEKPlayerViewSize, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.transform = CGAffineTransformMakeTranslation(0, - MEKPlayerViewSize);
    } completion:nil];
    
    //    [sv setContentOffset:CGPointMake(0, -CGRectGetHeight(sv.frame)) animated:NO];
    //    CGFloat pageWidth  = sv.frame.size.width;
    //    CGFloat pageHeight = sv.frame.size.height;
    //    CGRect rect = CGRectMake(0, 0, pageWidth, pageHeight);
    //    [sv scrollRectToVisible:rect animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 100)
    {
        [scrollView setContentOffset:CGPointMake(0, 100) animated:NO];
        
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
        [scrollView scrollRectToVisible:rect animated:YES];
        
        [self.playerViewController maximize];
        [self openPlayer];
    }
    
    NSLog(@"contentOffset: %f", scrollView.contentOffset.y);
    
    if (scrollView.contentOffset.y < -80)
    {
        NSLog(@"DOWN");
        [scrollView setContentOffset:CGPointMake(0, -80) animated:NO];
        
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
        [scrollView scrollRectToVisible:rect animated:YES];
        
        
        [self minimizePlayer];
    }
    
    //    UIView *view = self.tabBarController.view.subviews[0];
    //    [view setNeedsUpdateConstraints];
    //    CGFloat y = scrollView.contentOffset.y;
    //    CGFloat delta = - ((1 - 0.95)* y / 100);
    //    delta = 0.00;
    //    view.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.5 + delta, 0.5 + delta, 1.0);
}

-(void)closePlayer
{
    
}

-(void)minimizePlayer
{
    
    [self.playerViewController minimizeWithHeight:60];
    
    //CGRect frame = self.tabBarController.view.frame;
    CGFloat tabBarHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
    UIView *view = self.tabBarController.view.subviews[0];
    
    //[view setNeedsUpdateConstraints];
    
    
    //self.scrollView.transform = CGAffineTransformMakeTranslation(0, -MEKPlayerViewSize - self.scrollView.contentOffset.y );
    //[self.scrollView setContentOffset:CGPointZero];
    
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        //self.view.layer.backgroundColor = UIColor.blackColor.CGColor;
        self.darkView.alpha = 0.0;
        view.layer.cornerRadius = 0;

        self.playerViewController.view.layer.cornerRadius = 0;

        self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);

        view.layer.transform = CATransform3DMakeScale(1, 1, 1.0);
        self.scrollView.transform = CGAffineTransformMakeTranslation(0, -tabBarHeight - 60);
        
        //self.scrollView.frame = CGRectMake(0, CGRectGetHeight(frame) - tabBarHeight - 50, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        
        //self.playerViewController.view.transform = CGAffineTransformMakeTranslation(0, 250);
    } completion:nil];
}

-(void)maximizePlayer
{
    
}

@end
