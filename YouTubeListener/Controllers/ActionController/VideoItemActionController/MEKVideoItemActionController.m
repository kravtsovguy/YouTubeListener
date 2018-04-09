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
        _loader = [[MEKWebVideoLoader alloc] init];
        _loader.output = self;

        _qualityLoader = [[MEKWebVideoLoader alloc] init];
        _qualityLoader.output = self;

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

-(void)videoItemLoadInfo:(VideoItemMO *)item
{
    if (!item.videoId || !item.urls)
    {
        [self.loader loadVideoItem:item];
        return;
    }

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItemLoadInfo:item];
    }
}

- (void)videoItemPlay:(VideoItemMO *)item
{
    [self videoItemAddToHistory:item];

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

    VideoItemMO *item = [VideoItemMO videoItemForURL:url withContext:self.coreDataContext];
    if (!item)
    {
        item = [VideoItemMO disconnectedEntityWithContext:self.coreDataContext];
        item.originURL = url;

        [self.playLoader loadVideoItem:item];
    }

    [self videoItemPlay:item];
}

- (void)videoItemAddToHistory:(VideoItemMO *)item
{
    [item addToHistoryForUserDefaults:self.userDefaults];
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

- (void)videoItemRemoveHistory
{
    [VideoItemMO removeHistoryForUserDefaults:self.userDefaults];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItemRemoveHistory];
    }
}

- (void)videoItemRemoveAll
{
    NSArray<VideoItemMO *> *videoItemArray = [VideoItemMO executeFetchRequest:[VideoItemMO fetchRequest] withContext:self.coreDataContext];

    [videoItemArray enumerateObjectsUsingBlock:^(VideoItemMO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj deleteObject];
    }];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItemRemoveAll];
    }
}

#pragma mark MEKWebVideoLoaderOutputProtocol

- (void)webVideoLoader:(id<MEKWebVideoLoaderInputProtocol>)loader didLoadItem:(VideoItemMO *)item
{
    if (loader == self.loader)
    {
        [self videoItemLoadInfo:item];
    }

    if (loader == self.qualityLoader)
    {
        [self showDownloadQualityDialog:item];
    }

    if (loader == self.playLoader)
    {
        [self videoItemPlay:item];
    }
}

@end
