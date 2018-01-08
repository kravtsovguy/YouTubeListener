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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MEKPlayerController *player;
@property (nonatomic, strong) UITabBarController *tabBarController;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

