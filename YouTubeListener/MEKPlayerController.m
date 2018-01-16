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


static const CGFloat MEKPlayerViewMaximizedSize = 320;
static const CGFloat MEKPlayerViewMinimizedSize = 60;
static const NSTimeInterval MEKPlayerViewAnimationDuration = 0.3;

@interface MEKPlayerController () <UIScrollViewDelegate, MEKVideoPlayerViewControllerDelegate, MEKDownloadControllerDelegate, MEKVideoItemDelegate>

@property (nonatomic, strong) PlaylistMO *recentPlaylist;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MEKVideoPlayerViewController *playerViewController;

- (void)maximizePlayer;
- (void)minimizePlayer;
- (void)closePlayer;

- (UITabBarController*)tabBarController;
- (UIView*)tabBarMainView;
- (CGRect)mainFrame;

@end

@implementation MEKPlayerController

- (instancetype)initWithRecentPlaylist:(PlaylistMO *)recentPlaylist
{
    self = [super init];
    if (self)
    {
        _recentPlaylist = recentPlaylist;
    }
    
    return self;
}

-(UITabBarController *)tabBarController
{
    return ((AppDelegate*)[UIApplication sharedApplication].delegate).tabBarController;
}

-(UIView *)tabBarMainView
{
    return self.tabBarController.view.subviews[0];
}

- (CGRect)mainFrame
{
    return self.tabBarController.view.frame;
}

- (BOOL)isOpened
{
    return self.playerViewController != nil;
}

- (MEKPlayerVisibleState)visibleState
{
    CGFloat frameHeight = CGRectGetHeight(self.mainFrame);
    CGFloat tabbarHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
    CGFloat y = CGRectGetMinY(self.scrollView.frame);
    
    if (y == frameHeight - MEKPlayerViewMaximizedSize)
    {
        return MEKPlayerVisibleStateMaximized;
    }
    
    if (y == frameHeight - tabbarHeight - MEKPlayerViewMinimizedSize)
    {
        return MEKPlayerVisibleStateMinimized;
    }
    
    return MEKPlayerVisibleStateNone;
}

- (void)closePlayer
{
    [self.playerViewController.view removeFromSuperview];
    [self.playerViewController removeFromParentViewController];
    self.playerViewController = nil;
}

- (void)initPlayerViewControllerWithURL:(NSURL*) videoURL withVisibleState:(MEKPlayerVisibleState) state
{
    if (self.playerViewController)
        return;
    
    self.playerViewController = [[MEKVideoPlayerViewController alloc] initWithURL:videoURL];
    self.playerViewController.playerDelegate = self;
    self.playerViewController.delegate = self;
    
    if (state == MEKPlayerVisibleStateMinimized)
    {
        [self.playerViewController minimizeWithDuration:0 withHeight:MEKPlayerViewMinimizedSize];
    }
    
    if (state == MEKPlayerVisibleStateMaximized)
    {
        [self.playerViewController maximizeWithDuration:0];
    }
    
    
    [self.tabBarController addChildViewController:self.playerViewController];
    [self.playerViewController didMoveToParentViewController:self.tabBarController];
    
    [self.scrollView addSubview:self.playerViewController.view];
}

- (void)initScrollView
{
    if (self.scrollView)
        return;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.mainFrame), CGRectGetWidth(self.mainFrame), MEKPlayerViewMaximizedSize)];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.mainFrame), MEKPlayerViewMaximizedSize + 1);
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    
    [self.tabBarController.view insertSubview:self.scrollView aboveSubview:self.overlayView];
}

- (void)initOverlayView
{
    if (self.overlayView)
        return;
    
    self.overlayView = [[UIView alloc] initWithFrame:self.mainFrame];
    self.overlayView.backgroundColor = UIColor.blackColor;
    self.overlayView.alpha = 0;
    //self.darkView.translatesAutoresizingMaskIntoConstraints = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(minimize)];
    [self.overlayView addGestureRecognizer:tap];
    
    [self.tabBarController.view insertSubview:self.overlayView aboveSubview:self.tabBarMainView];
}

-(void)openURL:(NSURL *)videoURL
{
    [self openURL:videoURL withVisibleState:MEKPlayerVisibleStateMaximized];
}

-(void)openURL:(NSURL *)videoURL withVisibleState:(MEKPlayerVisibleState)state
{
    if (self.isOpened)
    {
        [self closePlayer];
    }
    
    [self initOverlayView];
    [self initScrollView];
    [self initPlayerViewControllerWithURL:videoURL withVisibleState:state];
    
    if (state == MEKPlayerVisibleStateMaximized)
        [self maximizePlayer];
    
    if (state == MEKPlayerVisibleStateMinimized)
        [self minimizePlayer];
}

- (void)fixContentInScrollView: (UIScrollView*) scrollView AtOffset: (CGPoint) offset
{
    [scrollView setContentOffset:offset animated:NO];
    
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
    [scrollView scrollRectToVisible:rect animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSLog(@"contentOffset: %f", scrollView.contentOffset.y);
    
    if (scrollView.contentOffset.y > 100)
    {
        [self fixContentInScrollView:scrollView AtOffset:CGPointMake(0, 100)];

        [self maximize];
    }
    
    if (scrollView.contentOffset.y < -80)
    {
        [self fixContentInScrollView:scrollView AtOffset:CGPointMake(0, -80)];
        
        [self minimize];
    }
}

- (void)downloadControllerProgress:(double)progress forKey:(NSString *)key
{
    if (![key isEqualToString:self.playerViewController.currentItem.videoId])
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playerViewController setDownloadingProgress:progress];
    });
}

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key
{
    if (![key isEqualToString:self.playerViewController.currentItem.videoId])
        return;
    
    [self.playerViewController.currentItem saveTempPathURL:url];
}

- (void)downloadControllerDidFinishWithError:(NSError *)error forKey:(NSString *)key
{
    if (![key isEqualToString:self.playerViewController.currentItem.videoId])
        return;
    
    
}

- (void)videoItemCancelDownload:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadForKey:item.videoId];
}

- (void)videoItemDownload:(VideoItemMO *)item withQuality:(YouTubeParserVideoQuality)quality
{
    self.downloadController.delegate = self;
    [self.downloadController downloadDataFromURL:item.urls[@(quality)] forKey:item.videoId];
}

-(void)videoItemAddToPlaylist:(VideoItemMO *)item
{
    [self.recentPlaylist addVideoItem:item];
}

-(void)videoItemAddToPlaylist:(VideoItemMO *)item playlist:(PlaylistMO *)playlist
{
    [playlist addVideoItem:item];
}

-(void)videoPlayerViewControllerClosed
{
    [self close];
}

-(void)close
{
    if (!self.isOpened)
        return;
    
    [self minimizePlayer];
    
    [UIView animateWithDuration:MEKPlayerViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        self.scrollView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self closePlayer];
    }];
}

- (void)minimizePlayerUI
{
    self.overlayView.alpha = 0.0;
    
    self.tabBarController.tabBar.transform = CGAffineTransformIdentity;
    
    //self.tabBarMainView.layer.transform = CATransform3DIdentity;
    self.tabBarMainView.layer.cornerRadius = 0;
    
    self.scrollView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.tabBarController.tabBar.frame) - MEKPlayerViewMinimizedSize);
}

- (void)maximizePlayerUI
{
    self.overlayView.alpha = 0.5;
    
    self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.tabBarController.tabBar.frame));
    
    self.tabBarMainView.layer.cornerRadius = 10;
    //self.tabBarMainView.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1.0);
    
    self.scrollView.transform = CGAffineTransformMakeTranslation(0, - MEKPlayerViewMaximizedSize);
}

- (void)minimizePlayer
{
    [self.tabBarMainView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:MEKPlayerViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self minimizePlayerUI];
    } completion:nil];
}

- (void)maximizePlayer
{
    [self.tabBarMainView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:MEKPlayerViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self maximizePlayerUI];
    } completion:nil];
}

-(void)minimize
{
    [self.playerViewController minimizeWithDuration:MEKPlayerViewAnimationDuration withHeight:MEKPlayerViewMinimizedSize];
    [self minimizePlayer];
}

-(void)maximize
{
    [self.playerViewController maximizeWithDuration:MEKPlayerViewAnimationDuration];
    [self maximizePlayer];
}

@end
