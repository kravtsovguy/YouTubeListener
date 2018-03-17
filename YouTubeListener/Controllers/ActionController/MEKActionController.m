//
//  MEKActionController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKActionController.h"
#import "AppDelegate.h"
#import "MEKAlertController.h"

@implementation MEKActionController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _alertController = [[MEKAlertController alloc] init];
    }
    return self;
}

#pragma mark Property

- (MEKPlayerController *)playerController
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;

    return appDelegate.playerController;
}
- (MEKVideoItemDownloadController *)downloadController
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;

    return appDelegate.downloadController;
}

- (NSManagedObjectContext *)coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;

    return appDelegate.persistentContainer.viewContext;
}

@end
