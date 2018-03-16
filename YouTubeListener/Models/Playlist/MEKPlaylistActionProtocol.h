//
//  MEKPlaylistActionProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoItemMO;
@class PlaylistMO;

@protocol MEKPlaylistActionProtocol <NSObject>

@optional

- (void)playlistCreate;
- (void)playlistCreateWithName: (NSString *)name;

- (void)playlistRename: (PlaylistMO *)playlist;
- (void)playlistRename: (PlaylistMO *)playlist toName: (NSString *)name;

- (void)playlist: (PlaylistMO *)playlist addVideoItem: (VideoItemMO *)item;
- (void)playlist: (PlaylistMO *)playlist removeVideoItem: (VideoItemMO *)item;

- (void)playlistRemove: (PlaylistMO *)playlist;
- (void)playlistForceRemove: (PlaylistMO *)playlist;

@end
