//
//  UIViewController+VideoItemActions.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 18/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIViewController+VideoItemActions.h"
#import "MEKModalPlaylistsViewController.h"

@implementation UIViewController(VideoItemActions)

#pragma mark - Public

- (void)vi_choosePlaylistForVideoItem:(VideoItemMO *)item
{
    MEKModalPlaylistsViewController *playlistsController = [[MEKModalPlaylistsViewController alloc] initWithVideoItem:item];
    
    if ([self conformsToProtocol:@protocol(MEKModalPlaylistsViewControllerDelegate)])
    {
        playlistsController.delegate = (id<MEKModalPlaylistsViewControllerDelegate>)self;
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    navController.navigationBar.prefersLargeTitles = YES;
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)vi_showDownloadingDialogForVideoItem: (VideoItemMO*) item handler:(void (^)(VideoItemQuality))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Quality"
                                                                   message:@"Available formats"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancedlAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel handler:nil];
    
    for (NSNumber *quality in [VideoItemMO getAllQualities])
    {
        NSNumber *size = item.sizes[quality];
        UIAlertAction *action = [self vi_createActionForQuality:quality.integerValue withSize:size handler:handler];
        [alert addAction:action];
    }
    
    [alert addAction:cancedlAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)vi_showQualityDialogForCurrentQuality: (VideoItemQuality)currentQuality handler:(void (^)(VideoItemQuality))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Quality"
                                                                   message:@"Available formats"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancedlAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel handler:nil];
    
    for (NSNumber *quality in [VideoItemMO getAllQualities])
    {
        UIAlertAction *action = [self vi_createActionForQuality:quality.integerValue withCurrentQuality:currentQuality handler:handler];
        [alert addAction:action];
    }
    
    [alert addAction:cancedlAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private

- (UIAlertAction*)vi_createActionForQuality: (VideoItemQuality) quality withSize: (NSNumber*) size handler:(void (^)(VideoItemQuality))handler;
{
    NSString *qualityString = [VideoItemMO getQualityString:quality];
    NSString *name = qualityString;
    
    if (![size isEqualToNumber:@(0)])
    {
        name = [NSString stringWithFormat:@"%@ (%.1f MB)", qualityString, size.doubleValue];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler)
        {
            handler(quality);
        }
    }];

    return action;
}

- (UIAlertAction*)vi_createActionForQuality: (VideoItemQuality) quality withCurrentQuality: (VideoItemQuality) currentQuality handler:(void (^)(VideoItemQuality))handler;
{
    NSString *qualityString = [VideoItemMO getQualityString:quality];
    NSString *name = qualityString;
    if (currentQuality == quality)
    {
        name = [NSString stringWithFormat:@"%@ (Current)", qualityString];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (handler)
        {
            handler(quality);
        }
    }];

    return action;
}

@end
