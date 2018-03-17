//
//  MEKPlaylistActionController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistActionController+Private.h"
#import "MEKPlaylistActionController+Alerts.h"
#import "PlaylistMO+CoreDataClass.h"
#import "MEKVideoItemActionController.h"

@implementation MEKPlaylistActionController

#pragma mark MEKPlaylistActionProtocol

- (void)playlistCreateWithName:(NSString *)name
{
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if (name.length == 0)
    {
        [self.alertController showAlertWithTitle:@"Incorrect playlist name" message:name];
        return;
    }

    PlaylistMO *player = [PlaylistMO playlistWithName:name withContext:self.coreDataContext];
    if (!player)
    {
        [self.alertController showAlertWithTitle:@"Playlist with this name already exists" message:name];
        return;
    }

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate playlistCreateWithName:name];
    }
}

- (void)playlistRename:(PlaylistMO *)playlist toName:(NSString *)name
{
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([playlist.name isEqualToString:name])
    {
        return;
    }

    if (name.length == 0)
    {
        [self.alertController showAlertWithTitle:@"Incorrect playlist name" message:name];
        return;
    }

    if (![playlist rename:name])
    {
        [self.alertController showAlertWithTitle:@"Playlist with this name already exists" message:name];
        return;
    }

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate playlistRename:playlist toName:name];
    }
}

- (void)playlistRemove:(PlaylistMO *)playlist
{
    [playlist deleteObject];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate playlistRemove:playlist];
    }
}

- (void)playlistsRemoveVideoItem:(VideoItemMO *)item
{
    NSArray<PlaylistMO *> *playlistArray = [PlaylistMO executeFetchRequest:[PlaylistMO fetchRequest] withContext:self.coreDataContext];

    [playlistArray enumerateObjectsUsingBlock:^(PlaylistMO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self playlist:obj removeVideoItem:item];
    }];
}

- (void)playlist:(PlaylistMO *)playlist removeVideoItem:(VideoItemMO *)item
{
    [playlist deleteVideoItem:item];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate playlist:playlist removeVideoItem:item];
    }
}

- (void)playlist:(PlaylistMO *)playlist addVideoItem:(VideoItemMO *)item
{
    [self.videoItemActionController videoItemAddToLibrary:item];
    [playlist addVideoItem:item];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate playlist:playlist addVideoItem:item];
    }
}

- (void)playlistRemoveAll
{
    NSArray<PlaylistMO *> *playlistArray = [PlaylistMO executeFetchRequest:[PlaylistMO fetchRequest] withContext:self.coreDataContext];

    [playlistArray enumerateObjectsUsingBlock:^(PlaylistMO * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj deleteObject];
    }];
}

@end
