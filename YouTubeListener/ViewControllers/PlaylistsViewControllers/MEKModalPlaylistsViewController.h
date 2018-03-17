//
//  MEKModalPlaylistsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCompletePlaylistsController.h"

@class PlaylistMO;
@class VideoItemMO;

@protocol MEKModalPlaylistsViewControllerDelegate <NSObject>

@required
- (void)modalPlaylistsViewControllerDidChoosePlaylist: (PlaylistMO*) playlist forVideoItem: (VideoItemMO*) item;

@end

@interface MEKModalPlaylistsViewController : MEKCompletePlaylistsController

@property (nonatomic, weak) id<MEKModalPlaylistsViewControllerDelegate> delegate;

- (instancetype)initWithVideoItem: (VideoItemMO*)item;

@end
