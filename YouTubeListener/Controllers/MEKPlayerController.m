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
#import "MEKWebVideoLoader.h"

static const NSTimeInterval MEKPlayerViewAnimationDuration = 0.3;

@interface MEKPlayerController () <UIScrollViewDelegate, MEKVideoPlayerViewControllerDelegate>

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

#pragma mark - Properties

- (NSManagedObjectContext*) coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    NSPersistentContainer *container = ((AppDelegate*)(application.delegate)).persistentContainer;
    
    NSManagedObjectContext *context = container.viewContext;
    
    return context;
}

- (UITabBarController *)tabBarController
{
    return ((AppDelegate*)[UIApplication sharedApplication].delegate).tabBarController;
}

- (UIView *)tabBarMainView
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
    
    if (y == frameHeight - MEKPlayerViewHeightSizeMaximized)
    {
        return MEKPlayerVisibleStateMaximized;
    }
    
    if (y == frameHeight - tabbarHeight - MEKPlayerViewHeightSizeMinimized)
    {
        return MEKPlayerVisibleStateMinimized;
    }
    
    return MEKPlayerVisibleStateNone;
}

#pragma mark - Public

- (BOOL)openURL:(NSURL *)videoURL
{
    return [self openURL:videoURL withVisibleState:MEKPlayerVisibleStateMinimized];
}

- (BOOL)openURL:(NSURL *)videoURL withVisibleState:(MEKPlayerVisibleState)state
{
    if (!videoURL)
    {
        return NO;
    }
    
    if (![MEKWebVideoLoader parserForURL:videoURL])
    {
        return NO;
    }
    
    VideoItemMO *item = [VideoItemMO getVideoItemForURL:videoURL withContext:self.coreDataContext];
    if (!item)
    {
        item = [VideoItemMO getEmptyWithContext:self.coreDataContext];
        item.originURL = videoURL;
    }
    
    [self openVideoItem:item withVisibleState:state];
    
    return YES;
}

- (void)openVideoItem:(VideoItemMO *)item
{
    [self openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];
}

- (void)openVideoItem:(VideoItemMO *)item withVisibleState:(MEKPlayerVisibleState)state
{
    if (self.isOpened)
    {
        [self closePlayer];
    }
    
    [self initOverlayView];
    [self initScrollView];
    [self initPlayerViewControllerWithVideoItem:item withVisibleState:state];
    
    if (state == MEKPlayerVisibleStateMaximized)
        [self maximizePlayer];
    
    if (state == MEKPlayerVisibleStateMinimized)
        [self minimizePlayer];
}

- (void)minimize
{
    [self.playerViewController minimizeWithDuration:MEKPlayerViewAnimationDuration];
    [self minimizePlayer];
}

- (void)maximize
{
    [self.playerViewController maximizeWithDuration:MEKPlayerViewAnimationDuration];
    [self maximizePlayer];
}

- (void)close
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

#pragma mark - Private

- (void)closePlayer
{
    [self.playerViewController.view removeFromSuperview];
    [self.playerViewController removeFromParentViewController];
    self.playerViewController = nil;
}

- (void)initPlayerViewControllerWithVideoItem:(VideoItemMO*) item withVisibleState:(MEKPlayerVisibleState) state
{
    if (self.playerViewController)
        return;
    
    self.playerViewController = [[MEKVideoPlayerViewController alloc] initWithVideoItem:item];
    self.playerViewController.delegate = self;
    
    if (state == MEKPlayerVisibleStateMinimized)
    {
        [self.playerViewController minimizeWithDuration:0];
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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.mainFrame), CGRectGetWidth(self.mainFrame), MEKPlayerViewHeightSizeMaximized)];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.mainFrame), MEKPlayerViewHeightSizeMaximized + 1);
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


- (void)minimizePlayerUI
{
    self.overlayView.alpha = 0.0;
    
    self.tabBarController.tabBar.transform = CGAffineTransformIdentity;
    
    //self.tabBarMainView.layer.transform = CATransform3DIdentity;
    self.tabBarMainView.layer.cornerRadius = 0;
    
    self.scrollView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.tabBarController.tabBar.frame) - MEKPlayerViewHeightSizeMinimized);
}

- (void)maximizePlayerUI
{
    self.overlayView.alpha = 0.5;
    
    self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.tabBarController.tabBar.frame));
    
    self.tabBarMainView.layer.cornerRadius = 10;
    //self.tabBarMainView.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1.0);
    
    self.scrollView.transform = CGAffineTransformMakeTranslation(0, - MEKPlayerViewHeightSizeMaximized);
}

- (void)minimizePlayer
{
    [self topViewWillAppear];
    
    [self.tabBarMainView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:MEKPlayerViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self minimizePlayerUI];
    } completion:nil];
}

- (void)maximizePlayer
{
    [self playerViewWillAppear];
    
    [self.tabBarMainView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:MEKPlayerViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self maximizePlayerUI];
    } completion:nil];
}

- (void)fixContentInScrollView: (UIScrollView*) scrollView AtOffset: (CGPoint) offset
{
    [scrollView setContentOffset:offset animated:NO];
    
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
    [scrollView scrollRectToVisible:rect animated:YES];
}

- (void)topViewWillAppear
{
    UIViewController *navController = self.tabBarController.selectedViewController;
    [navController viewWillAppear:NO];
    if ([navController isKindOfClass:[UINavigationController class]])
    {
        id vc = ((UINavigationController*)navController).topViewController;
        [vc viewWillAppear:NO];
    }
}

- (void)playerViewWillAppear
{
    [self.playerViewController viewWillAppear:NO];
}

#pragma mark - UIScrollViewDelegate

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

#pragma mark - MEKVideoPlayerViewControllerDelegate

- (void)videoPlayerViewControllerOpen
{
    [self maximize];
}

- (void)videoPlayerViewControllerClosed
{
    [self close];
}

@end
