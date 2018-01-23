//
//  AppDelegate.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MEKPlayerController.h"
#import "MEKVideoItemDownloadController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (nonatomic, readonly) MEKPlayerController *playerController;
@property (nonatomic, readonly) MEKVideoItemDownloadController *downloadController;

- (void)saveContext;


@end

