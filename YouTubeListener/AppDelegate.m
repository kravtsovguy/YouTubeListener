//
//  AppDelegate.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MEKSearchViewController.h"

@interface AppDelegate () <UIScrollViewDelegate>

@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.window = [UIWindow new];
    
    MEKSearchViewController *vc = [MEKSearchViewController new];
    vc.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:1];
    
    self.tabBarController = [UITabBarController new];
    self.tabBarController.viewControllers = @[vc];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)openVideoController
{
    CGRect frame = self.tabBarController.view.frame;
    
    UIView *view = self.tabBarController.view.subviews[0];
    view.layer.masksToBounds = YES;
    
    UIView *darkView = [[UIView alloc] initWithFrame:frame];
    darkView.backgroundColor = UIColor.blackColor;
    darkView.alpha = 0;
    //darkView.translatesAutoresizingMaskIntoConstraints = NO;
    darkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:darkView];
    
    //view.frame = CGRectOffset(view.frame, 50, 50);
    
    [view setNeedsUpdateConstraints];
    
    //view.layer.anchorPoint = CGPointMake(0, 0);
    //darkView.layer.anchorPoint = CGPointMake(0, 0);

    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        //self.view.layer.backgroundColor = UIColor.blackColor.CGColor;
        darkView.alpha = 0.5;
        view.layer.cornerRadius = 20;
        
        self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.tabBarController.tabBar.frame));
        
        view.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1.0);

        //view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
        //view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        //self.view.superview.layer.sublayerTransform = CATransform3DMakeScale(0.9, 0.9, 1.0);
        //self.view.layer.sublayerTransform = CATransform3DMakeScale(0.9, 0.9, 1.0);
    } completion:nil];
    
    
    ViewController *vc = [ViewController new];

    [self.tabBarController addChildViewController:vc];
    [vc.view setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    vc.view.layer.cornerRadius = 20;
    vc.view.layer.masksToBounds = YES;
    //[self.tabBarController.view addSubview:vc.view];
    [vc didMoveToParentViewController:self.tabBarController];
    
    CGFloat size = 400;
    //CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame), CGRectGetWidth(frame), size)];
    //sv.backgroundColor = UIColor.grayColor;
    sv.showsVerticalScrollIndicator = NO;
    sv.contentSize = CGSizeMake(CGRectGetWidth(frame), size + 1);//self.view.frame.size.height * 1.1);
    sv.clipsToBounds = NO;
    sv.delegate = self;
    //sv.scrollEnabled = YES;
    //sv.bounces = NO;
    //[sv setContentOffset:CGPointZero animated:YES];
    [sv addSubview:vc.view];

    [self.tabBarController.view insertSubview:sv atIndex:1];
    //[self.tabBarController.view.subviews[0] addSubview:sv];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        //self.view.layer.backgroundColor = UIColor.blackColor.CGColor;
        sv.transform = CGAffineTransformMakeTranslation(0, - size);
    } completion:nil];

//    [sv setContentOffset:CGPointMake(0, -CGRectGetHeight(sv.frame)) animated:NO];
//    CGFloat pageWidth  = sv.frame.size.width;
//    CGFloat pageHeight = sv.frame.size.height;
//    CGRect rect = CGRectMake(0, 0, pageWidth, pageHeight);
//    [sv scrollRectToVisible:rect animated:YES];
    
}


- (void)goDownPlayer
{
    
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
        [self goDownPlayer];
    }
    
//    UIView *view = self.tabBarController.view.subviews[0];
//    [view setNeedsUpdateConstraints];
//    CGFloat y = scrollView.contentOffset.y;
//    CGFloat delta = - ((1 - 0.95)* y / 100);
//    delta = 0.00;
//    view.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.5 + delta, 0.5 + delta, 1.0);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"YouTubeListener"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
