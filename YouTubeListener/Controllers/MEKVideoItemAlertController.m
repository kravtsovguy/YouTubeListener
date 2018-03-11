//
//  MEKVideoItemAlertController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 08/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemAlertController.h"
#import "MEKModalPlaylistsViewController.h"
#import "VideoItemMO+CoreDataClass.h"
#import "MEKVideoItemActionController.h"
#import "AppDelegate.h"

@interface MEKVideoItemAlertController () <MEKModalPlaylistsViewControllerDelegate>

@end

@implementation MEKVideoItemAlertController

#pragma mark init

- (instancetype)init
{
    UIApplication *application = [UIApplication sharedApplication];
    UIViewController *viewController = application.keyWindow.rootViewController;

    return [self initWithViewController:viewController];
}

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        _viewController = viewController;
    }
    return self;
}

#pragma mark Properties

- (NSManagedObjectContext *)coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;

    return appDelegate.persistentContainer.viewContext;
}

#pragma mark Public

- (void)showPlaylistSelectionForVideoItem:(VideoItemMO *)item
{
    MEKModalPlaylistsViewController *playlistsController = [[MEKModalPlaylistsViewController alloc] initWithVideoItem:item];
    playlistsController.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    navController.navigationBar.prefersLargeTitles = YES;

    [self.viewController presentViewController:navController animated:YES completion:nil];
}

- (void)showActionsForVideoItem:(VideoItemMO *)item
{
    [self p_showDialogWithTitle:@"" message:@"Choose Action" actions:[self p_actionsForVideoItem:item]];
}

- (void)showDownloadingDialogForVideoItem: (VideoItemMO*)item
{
    [self p_showDialogWithTitle:@"Select Quality" message:@"Available formats" actions:[self p_downloadActionsForVideoItem:item]];
}

#pragma mark Private

- (UIAlertAction *)p_actionWithTitle: (NSString *)title handler: (void (^ __nullable)(void)) handler
{
    return [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler();
    }];
}

- (void)p_showDialogWithTitle: (NSString *)title message: (NSString *)message actions: (NSArray<UIAlertAction *> *)actions
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [actions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull action, NSUInteger idx, BOOL * _Nonnull stop) {
        [alert addAction:action];
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (NSArray<UIAlertAction *> *)p_actionsForVideoItem: (VideoItemMO *)item
{
    NSMutableArray *actions = @[].mutableCopy;

    BOOL inLibrary = [item addedToLibrary:self.coreDataContext];
    BOOL downloaded = [item hasDownloaded];

    if (inLibrary)
    {
        if (downloaded)
        {
            [actions addObject: [self p_actionWithTitle:@"Remove from Library" handler:^{
                [self.delegate videoItemRemoveFromLibrary:item];
            }]];

            [actions addObject: [self p_actionWithTitle:@"Remove Download" handler:^{
                [self.delegate videoItemRemoveDownload:item];
            }]];
        }
        else
        {
            [actions addObject: [self p_actionWithTitle:@"Download" handler:^{
                [self.delegate videoItemDownload:item];
            }]];

            [actions addObject: [self p_actionWithTitle:@"Remove from Library" handler:^{
                [self.delegate videoItemRemoveFromLibrary:item];
            }]];
        }
    }
    else
    {
        [actions addObject: [self p_actionWithTitle:@"Add to Library" handler:^{
            [self.delegate videoItemAddToLibrary:item];
        }]];
    }

    [actions addObject: [self p_actionWithTitle:@"Add to a Playlist" handler:^{
        [self.delegate videoItemAddToPlaylist:item];
    }]];

    [actions addObject: [self p_actionWithTitle:@"Open in YouTube" handler:^{
        [self.delegate videoItemOpenURL:item];
    }]];

    return actions;
}

- (NSArray<UIAlertAction *> *)p_downloadActionsForVideoItem: (VideoItemMO *)item
{
    NSMutableArray *actions = @[].mutableCopy;

    NSArray<NSNumber *> *qualities = [VideoItemMO getAllQualities];
    [qualities enumerateObjectsUsingBlock:^(NSNumber * _Nonnull qualityNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        VideoItemQuality quality = qualityNumber.integerValue;
        NSNumber *size = item.sizes[qualityNumber];
        NSString *qualityString = [VideoItemMO getQualityString:quality];
        NSString *title = [NSString stringWithFormat:@"%@ (%.1f MB)", qualityString, size.doubleValue];

        [actions addObject: [self p_actionWithTitle:title handler:^{
            [self.delegate videoItem:item downloadWithQuality:quality];
        }]];
    }];

    return actions;
}

#pragma mark MEKModalPlaylistsViewControllerDelegate

- (void)modalPlaylistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist forVideoItem:(VideoItemMO *)item
{
    [self.delegate videoItem:item addToPlaylist:playlist];
}

@end
