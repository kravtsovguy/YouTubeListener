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

@property (nonatomic, strong) MEKPlayerController *playerController;
@property (nonatomic, strong) MEKVideoItemDownloadController *downloadController;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

