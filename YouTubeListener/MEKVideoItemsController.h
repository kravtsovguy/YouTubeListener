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

- (void)addPlaylistWithName: (NSString*) name;
- (void)addVideoItem: (VideoItemMO*) item toPlaylist: (PlaylistMO*) playlist;
- (NSArray<PlaylistMO*>*)getPlaylists;

- (PlaylistMO*)getEmptyPlaylist;
- (void)savePlaylist: (PlaylistMO*) playlist;
- (void)deletePlaylist: (PlaylistMO*) playlist;

- (VideoItemMO*)getEmptyVideoItem;
- (void)saveVideoItem: (VideoItemMO*) item;
- (void)deleteVideoItem: (VideoItemMO*) item;

@end
