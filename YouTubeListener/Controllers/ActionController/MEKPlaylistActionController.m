//
//  MEKPlaylistActionController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistActionController.h"
#import "MEKPlaylistAlertController.h"
#import "PlaylistMO+CoreDataClass.h"

@interface MEKPlaylistActionController ()

@property (nonatomic, strong) MEKPlaylistAlertController *alertController;

@end

@implementation MEKPlaylistActionController

#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _alertController = [[MEKPlaylistAlertController alloc] init];
        _alertController.delegate = self;
    }
    return self;
}

#pragma mark MEKPlaylistActionProtocol

- (void)playlistCreate
{
    [self.alertController showCreatePlaylistDialog];
}

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

- (void)playlistRename:(PlaylistMO *)playlist
{
    [self.alertController showRenameDialogForPlaylist:playlist];
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
    [self.alertController showRemoveDialogForPlaylist:playlist];
}

- (void)playlistForceRemove:(PlaylistMO *)playlist
{
    [playlist deleteObject];

    if ([self.delegate respondsToSelector:_cmd])
    {
        [self.delegate playlistForceRemove:playlist];
    }
}
@end
