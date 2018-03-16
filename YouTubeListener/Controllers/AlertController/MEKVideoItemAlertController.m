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

@interface MEKVideoItemAlertController () <MEKModalPlaylistsViewControllerDelegate>

@end

@implementation MEKVideoItemAlertController

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
    [self showDialogWithTitle:@"" message:@"Choose Action" actions:[self p_actionsForVideoItem:item]];
}

- (void)showDownloadingDialogForVideoItem: (VideoItemMO*)item
{
    [self showDialogWithTitle:@"Select Quality" message:@"Available formats" actions:[self p_downloadActionsForVideoItem:item]];
}

#pragma mark Private

- (NSArray<UIAlertAction *> *)p_actionsForVideoItem: (VideoItemMO *)item
{
    NSMutableArray *actions = @[].mutableCopy;

    BOOL inLibrary = [item addedToLibrary:self.coreDataContext];
    BOOL downloaded = [item hasDownloaded];

    if (inLibrary)
    {
        if (downloaded)
        {
            [actions addObject: [self actionWithTitle:@"Remove from Library" handler:^{
                [self.delegate videoItemRemoveFromLibrary:item];
            }]];

            [actions addObject: [self actionWithTitle:@"Remove Download" handler:^{
                [self.delegate videoItemRemoveDownload:item];
            }]];
        }
        else
        {
            [actions addObject: [self actionWithTitle:@"Download" handler:^{
                [self.delegate videoItemDownload:item];
            }]];

            [actions addObject: [self actionWithTitle:@"Remove from Library" handler:^{
                [self.delegate videoItemRemoveFromLibrary:item];
            }]];
        }
    }
    else
    {
        [actions addObject: [self actionWithTitle:@"Add to Library" handler:^{
            [self.delegate videoItemAddToLibrary:item];
        }]];
    }

    [actions addObject: [self actionWithTitle:@"Add to a Playlist" handler:^{
        [self.delegate videoItemAddToPlaylist:item];
    }]];

    [actions addObject: [self actionWithTitle:@"Open in YouTube" handler:^{
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

        [actions addObject: [self actionWithTitle:title handler:^{
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
