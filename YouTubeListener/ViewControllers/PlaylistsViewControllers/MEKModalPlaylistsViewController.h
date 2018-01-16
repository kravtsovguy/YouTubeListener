//
//  MEKModalPlaylistsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistsViewController.h"

@protocol MEKModalPlaylistsViewControllerDelegate <NSObject>

@required
- (void)modalPlaylistsViewControllerDidChoosePlaylist: (PlaylistMO*) playlist;

@end

@interface MEKModalPlaylistsViewController : MEKPlaylistsViewController

@property (nonatomic, weak) id<MEKModalPlaylistsViewControllerDelegate> delegate;

@end
