//
//  MEKVideoItemActionController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 07/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemActionController.h"
#import "VideoItemMO+CoreDataClass.h"
#import "PlaylistMO+CoreDataClass.h"
#import "MEKVideoItemDownloadController.h"
#import "MEKWebVideoLoader.h"
#import "MEKVideoItemAlertController.h"
#import "MEKPlayerController.h"

@interface MEKVideoItemActionController () <MEKWebVideoLoaderOutputProtocol>

@property (nonatomic, strong) MEKWebVideoLoader *downloadLoader;
@property (nonatomic, strong) MEKWebVideoLoader *playLoader;
@property (nonatomic, strong) MEKVideoItemAlertController *alertController;

@end

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

        _alertController = [[MEKVideoItemAlertController alloc] init];
        _alertController.delegate = self;
    }
    return self;
}

#pragma mark Property

- (NSUserDefaults *)userDefaults
{
    return _userDefaults ?: [NSUserDefaults standardUserDefaults];
}

#pragma mark MEKVideoItemActionProtocol

- (void)videoItemShowActions:(VideoItemMO *)item
{
    [self.alertController showActionsForVideoItem:item];
}

- (void)videoItemPlay:(VideoItemMO *)item
{
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

    [self.playLoader loadVideoItem:item];
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
    [self videoItemCancelDownload:item];

    NSArray<PlaylistMO *> *playlists = [PlaylistMO getPlaylistsWithContext:self.coreDataContext];
    [playlists enumerateObjectsUsingBlock:^(PlaylistMO * _Nonnull playlist, NSUInteger idx, BOOL * _Nonnull stop) {
        [self videoItem:item removeFromPlaylist:playlist];
    }];

    [item removeFromLibrary: self.coreDataContext];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItemRemoveFromLibrary:item];
    }
}

- (void)videoItemAddToPlaylist:(VideoItemMO *)item
{
    [self.alertController showPlaylistSelectionForVideoItem:item];
}

- (void)videoItem:(VideoItemMO *)item addToPlaylist:(PlaylistMO *)playlist
{
    [self videoItemAddToLibrary:item];
    [playlist addVideoItem:item];
}

- (void)videoItem:(VideoItemMO *)item removeFromPlaylist:(PlaylistMO *)playlist
{
    [playlist deleteVideoItem:item];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate videoItem:item removeFromPlaylist:playlist];
    }
}

- (void)videoItemDownload:(VideoItemMO *)item
{
    if (item.urls)
    {
        [self.alertController showDownloadingDialogForVideoItem:item];
    }
    else
    {
        [self.downloadLoader loadVideoItem:item];
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

#pragma mark MEKWebVideoLoaderOutputProtocol

- (void)webVideoLoader:(id<MEKWebVideoLoaderInputProtocol>)loader didLoadItem:(VideoItemMO *)item
{
    if (loader == self.downloadLoader)
    {
        [self videoItemDownload:item];
    }

    if (loader == self.playLoader)
    {
        [self videoItemPlay:item];
    }
}

@end