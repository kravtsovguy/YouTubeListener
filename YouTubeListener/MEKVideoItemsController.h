//
//  MEKVideoItemsController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistMO+CoreDataClass.h"
#import "VideoItemMO+CoreDataClass.h"

@interface MEKVideoItemsController : NSObject

- (void)renamePlaylist: (PlaylistMO*) playlist toName: (NSString*) name;
- (PlaylistMO*)addPlaylistWithName: (NSString*) name;
- (void)addVideoItem: (VideoItemMO*) item toPlaylist: (PlaylistMO*) playlist;
- (void)addVideoItemToRecentPlaylist: (VideoItemMO*) item;
- (NSArray<PlaylistMO*>*)getPlaylists;
- (PlaylistMO*)getRecentPlaylist;
- (PlaylistMO*)getPlaylistForName: (NSString*) name;
- (VideoItemMO*)getVideoItemForId: (NSString*) videoId;
- (VideoItemMO*)getFirstVideoItemForPlaylist: (PlaylistMO*) playlist;

- (BOOL)containsVideoItem: (VideoItemMO*) item forPlaylist: (PlaylistMO*) playlist;

- (NSArray<VideoItemMO*>*)getVideoItems;
- (NSArray<VideoItemMO*>*)getVideoItemsForPlaylist: (PlaylistMO*) playlist;

- (PlaylistMO*)getEmptyPlaylist;
- (void)savePlaylist: (PlaylistMO*) playlist;
- (void)deletePlaylist: (PlaylistMO*) playlist;

- (VideoItemMO*)getEmptyVideoItem;
- (void)saveVideoItem: (VideoItemMO*) item;
- (void)deleteVideoItem: (VideoItemMO*) item;
- (void)deleteVideoItem: (VideoItemMO*) item fromPlaylist: (PlaylistMO*) playlist;
@end
