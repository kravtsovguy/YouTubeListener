//
//  MEKVideoItemActionController+Alerts.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemActionController+Alerts.h"
#import "MEKVideoItemActionController+Private.h"
#import "MEKPlaylistActionController+Alerts.h"

@implementation MEKVideoItemActionController (Alerts)

- (void)showActionDialog:(VideoItemMO *)item
{
    [self.alertController showDialogWithTitle:@"" message:@"Choose Action" actions:[self p_actionsForVideoItem:item]];
}

- (void)showDownloadQualityDialog:(VideoItemMO *)item
{
    if (item.urls)
    {
        [self.alertController showDialogWithTitle:@"Select Quality" message:@"Available formats" actions:[self p_downloadActionsForVideoItem:item]];
    }
    else
    {
        [self.qualityLoader loadVideoItem:item];
    }
}

- (void)showPlayQualityDialog:(VideoItemMO *)item withCurrentQuality:(VideoItemQuality)currentQuality
{
    [self.alertController showDialogWithTitle:@"Select Quality" message:@"Available formats" actions:[self p_qualityActionsForVideoItem:item withCurrentQuality:currentQuality]];
}

- (void)showRemoveHistoryDialog
{
    UIAlertAction *action = [self.alertController actionWithTitle:@"Clear" handler:^{
        [self videoItemRemoveHistory];
    }];

    [self.alertController showDialogWithTitle:@"" message:@"Clear your history?" actions:@[action]];
}

#pragma mark Private

- (NSArray<UIAlertAction *> *)p_actionsForVideoItem:(VideoItemMO *)item
{
    NSMutableArray *actions = @[].mutableCopy;

    BOOL inLibrary = [item addedToLibrary:self.coreDataContext];
    BOOL downloaded = [item hasDownloaded];

    if (inLibrary)
    {
        if (downloaded)
        {
            [actions addObject: [self.alertController actionWithTitle:@"Remove from Library" handler:^{
                [self videoItemRemoveFromLibrary:item];
            }]];

            [actions addObject: [self.alertController actionWithTitle:@"Remove Download" handler:^{
                [self videoItemRemoveDownload:item];
            }]];
        }
        else
        {
            [actions addObject: [self.alertController actionWithTitle:@"Download" handler:^{
                [self showDownloadQualityDialog:item];
            }]];

            [actions addObject: [self.alertController actionWithTitle:@"Remove from Library" handler:^{
                [self videoItemRemoveFromLibrary:item];
            }]];
        }
    }
    else
    {
        [actions addObject: [self.alertController actionWithTitle:@"Add to Library" handler:^{
            [self videoItemAddToLibrary:item];
        }]];
    }

    [actions addObject: [self.alertController actionWithTitle:@"Add to a Playlist" handler:^{
        [self.playlistActionController showChoosePlaylistDialogForVideoItem:item];
    }]];

    [actions addObject: [self.alertController actionWithTitle:@"Open in YouTube" handler:^{
        [self videoItemOpenURL:item];
    }]];

    return actions;
}

- (NSArray<UIAlertAction *> *)p_downloadActionsForVideoItem:(VideoItemMO *)item
{
    NSMutableArray *actions = @[].mutableCopy;

    NSArray<NSNumber *> *qualities = [VideoItemMO allQualities];
    [qualities enumerateObjectsUsingBlock:^(NSNumber * _Nonnull qualityNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        VideoItemQuality quality = qualityNumber.integerValue;
        NSString *qualityString = [VideoItemMO qualityString:quality];
        NSNumber *size = item.sizes[qualityNumber];
        NSString *title = [NSString stringWithFormat:@"%@ (%.1f MB)", qualityString, size.doubleValue];

        [actions addObject: [self.alertController actionWithTitle:title handler:^{
            [self videoItem:item downloadWithQuality:quality];
        }]];
    }];

    return actions;
}

- (NSArray<UIAlertAction *> *)p_qualityActionsForVideoItem:(VideoItemMO *)item withCurrentQuality:(VideoItemQuality)currentQuality
{
    NSMutableArray *actions = @[].mutableCopy;

    NSArray<NSNumber *> *qualities = [VideoItemMO allQualities];
    [qualities enumerateObjectsUsingBlock:^(NSNumber * _Nonnull qualityNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        VideoItemQuality quality = qualityNumber.integerValue;
        NSString *qualityString = [VideoItemMO qualityString:quality];
        NSString *title = [NSString stringWithFormat:@"%@%@", qualityString, currentQuality == quality ? @" (Current)" : @""];

        [actions addObject: [self.alertController actionWithTitle:title handler:^{
            [self.delegate videoItem:item playWithQuality:quality];
        }]];
    }];

    return actions;
}

@end
