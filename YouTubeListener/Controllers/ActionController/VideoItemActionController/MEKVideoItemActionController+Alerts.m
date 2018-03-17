//
//  MEKVideoItemActionController+Alerts.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemActionController+Alerts.h"
#import "MEKVideoItemActionController+Private.h"
#import "VideoItemMO+CoreDataClass.h"
#import "MEKWebVideoLoader.h"
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
        [self.downloadLoader loadVideoItem:item];
    }
}

- (void)showPlayQualityDialog:(VideoItemMO *)item
{

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

- (NSArray<UIAlertAction *> *)p_downloadActionsForVideoItem: (VideoItemMO *)item
{
    NSMutableArray *actions = @[].mutableCopy;

    NSArray<NSNumber *> *qualities = [VideoItemMO getAllQualities];
    [qualities enumerateObjectsUsingBlock:^(NSNumber * _Nonnull qualityNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        VideoItemQuality quality = qualityNumber.integerValue;
        NSNumber *size = item.sizes[qualityNumber];
        NSString *qualityString = [VideoItemMO getQualityString:quality];
        NSString *title = [NSString stringWithFormat:@"%@ (%.1f MB)", qualityString, size.doubleValue];

        [actions addObject: [self.alertController actionWithTitle:title handler:^{
            [self videoItem:item downloadWithQuality:quality];
        }]];
    }];

    return actions;
}

@end
