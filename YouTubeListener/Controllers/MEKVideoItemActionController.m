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
#import "AppDelegate.h"
#import "MEKVideoItemAlertController.h"

@interface MEKVideoItemActionController () <MEKWebVideoLoaderOutputProtocol>

@property (nonatomic, strong) MEKWebVideoLoader *loader;
@property (nonatomic, strong) MEKVideoItemAlertController *alertController;

@end

@implementation MEKVideoItemActionController

#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _loader = [[MEKWebVideoLoader alloc] init];
        _loader.output = self;

        _alertController = [[MEKVideoItemAlertController alloc] init];
        _alertController.delegate = self;
    }
    return self;
}

#pragma mark Property

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

#pragma mark MEKVideoItemActionProtocol

- (void)videoItemShowActions:(VideoItemMO *)item
{
    [self.alertController showActionsForVideoItem:item];
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

    [item removeFromLibrary];

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
        [self.loader loadVideoItem:item];
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
    [self videoItemDownload:item];
}

@end
