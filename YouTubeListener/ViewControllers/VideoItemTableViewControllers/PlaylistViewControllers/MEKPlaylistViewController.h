//
//  MEKPlaylistViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemTableViewController.h"

@class PlaylistMO;

@interface MEKPlaylistViewController : MEKVideoItemTableViewController

@property (nonatomic, readonly) PlaylistMO *playlist;

- (instancetype)initWithPlaylist: (PlaylistMO*) playlist;

@end
