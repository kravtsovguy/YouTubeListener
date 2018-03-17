//
//  MEKVideoItemActionController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 07/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemActionController+Private.h"
#import "MEKVideoItemActionController+Alerts.h"
#import "MEKPlayerController.h"
#import "MEKVideoItemDownloadController.h"
#import "MEKPlaylistActionController.h"

@implementation MEKVideoItemActionController

#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _downloadLoader = [[MEKWebVideoLoader alloc] init];
        _downloadLoader.output = self;

        _playLoader = [[MEKWebVideoLoader alloc] init];
        _playLoader.output = self;
    }
    return self;
}

#pragma mark Properties

- (NSUserDefaults *)userDefaults
{
    return _userDefaults ?: [NSUserDefaults standardUserDefaults];
}

#pragma mark MEKVideoItemActionProtocol

- (void)videoItemPlay:(VideoItemMO *)item
{
    if (!item.urls)
    {
        [self.playLoader loadVideoItem:item];
        return;
    }

    [item addToHistoryForUserDefaults:self.userDefaults];

    [self.playerController openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItemPlay:item];
    }
}

- (void)videoItemPlayURL:(NSURL *)url
{
    if (!url || ![MEKWebVideoLoader parserForURL:url])
    {
        [self.alertController showAlertWithTitle:@"Can't Parse Given Url" message:url.absoluteString];
        return;
    }

    VideoItemMO *item = [VideoItemMO getVideoItemForURL:url withContext:self.coreDataContext];
    if (!item)
    {
        item = [VideoItemMO disconnectedEntityWithContext:self.coreDataContext];
        item.originURL = url;
    }

    [self videoItemPlay:item];
}

- (void)videoItemAddToLibrary:(VideoItemMO *)item
{
    [item addToLibrary:self.coreDataContext];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItemAddToLibrary:item];
    }
}

- (void)videoItemRemoveFromLibrary:(VideoItemMO *)item
{
    [self.playlistActionController playlistsRemoveVideoItem:item];
    [self videoItemCancelDownload:item];
    [item removeFromLibrary: self.coreDataContext];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItemRemoveFromLibrary:item];
    }
}

- (void)videoItem:(VideoItemMO *)item downloadWithQuality:(VideoItemQuality)quality
{
    [self.downloadController downloadVideoItem:item withQuality:quality];
}

- (void)videoItemCancelDownload:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadingVideoItem:item];
}

- (void)videoItemRemoveDownload:(VideoItemMO *)item
{
    [item removeAllDownloads];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItemRemoveDownload:item];
    }
}

- (void)videoItemOpenURL:(VideoItemMO *)item
{
    [[UIApplication sharedApplication] openURL:item.originURL options:@{} completionHandler:^(BOOL success) {}];
}

- (void)videoItemRemoveAll
{
    NSArray<VideoItemMO *> *videoItemArray = [VideoItemMO executeFetchRequest:[VideoItemMO fetchRequest] withContext:self.coreDataContext];

    [videoItemArray enumerateObjectsUsingBlock:^(VideoItemMO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj deleteObject];
    }];
}

#pragma mark MEKWebVideoLoaderOutputProtocol

- (void)webVideoLoader:(id<MEKWebVideoLoaderInputProtocol>)loader didLoadItem:(VideoItemMO *)item
{
    if (loader == self.downloadLoader)
    {
        [self showDownloadQualityDialog:item];
    }

    if (loader == self.playLoader)
    {
        [self videoItemPlay:item];
    }
}

@end
