//
//  AppDelegate.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "AppDelegate.h"
#import "MEKVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MEKPlaylistsViewController.h"
#import "MEKDownloadsPlaylistViewController.h"
#import "MEKYouTubeAPI.h"
#import "MEKCachedSearchViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) MEKPlayerController *playerController;
@property (nonatomic, strong) MEKVideoItemDownloadController *downloadController;

@property (nonatomic, strong) UIViewController *searchViewController;
@property (nonatomic, strong) UIViewController *playlistsViewController;
@property (nonatomic, strong) UIViewController *downloadsPlaylistViewController;

@end

@implementation AppDelegate

#pragma mark - Init View Controllers

- (UIViewController*)searchViewController
{
    MEKSearchViewController *searchViewController = [[MEKCachedSearchViewController alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    navigationController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
    [navigationController.tabBarItem setValue:@"Search" forKey:@"internalTitle"];
    navigationController.navigationBar.prefersLargeTitles = YES;

    return navigationController;
}

- (UIViewController*)playlistsViewController
{
    MEKPlaylistsViewController *playlistsViewController = [MEKPlaylistsViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:playlistsViewController];
    navigationController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostViewed tag:1];
    [navigationController.tabBarItem setValue:@"Playlists" forKey:@"internalTitle"];
    navigationController.navigationBar.prefersLargeTitles = YES;
    
    return navigationController;
}

- (UIViewController*)downloadsPlaylistViewController
{
    MEKDownloadsPlaylistViewController *downloadsPlaylistViewController = [MEKDownloadsPlaylistViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:downloadsPlaylistViewController];
    navigationController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:2];
    [navigationController.tabBarItem setValue:@"Downloads" forKey:@"internalTitle"];
    navigationController.navigationBar.prefersLargeTitles = YES;
    
    return navigationController;
}

#pragma mark - Init Tab Bar

- (void)initTabBarController
{
    self.tabBarController = [UITabBarController new];
    self.tabBarController.viewControllers = @[self.searchViewController, self.playlistsViewController, self.downloadsPlaylistViewController];
}

#pragma mark - Init Window

- (void)initWindow
{
    self.window = [UIWindow new];
    self.window.tintColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
    
    [self initTabBarController];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
}

#pragma mark - Init Controllers

- (void)initPlayerController
{
    self.playerController = [MEKPlayerController new];
}

- (void)initDownloadController
{
    MEKDownloadController *downloadController = [[MEKDownloadController alloc] initWithBackgroundMode:YES];
    self.downloadController = [[MEKVideoItemDownloadController alloc] initWithDownloadController:downloadController];
}

- (void)initControllers
{
    [self initDownloadController];
    [self initPlayerController];
}

#pragma mark - Settings

- (void)makeSettings
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)playExampleVideoIfNeeded
{
    NSArray *items = [VideoItemMO getVideoItemsWithContext:self.persistentContainer.viewContext];
    if (items.count == 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSURL *url = [NSURL URLWithString:@"https://youtu.be/RpgR0c9Y8OQ"];
            [self.playerController openURL:url withVisibleState:MEKPlayerVisibleStateMaximized];
        });
    }
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self makeSettings];
    [self initControllers];
    [self initWindow];
    
    [self playExampleVideoIfNeeded];

    return YES;
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
