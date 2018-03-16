//
//  MEKPlaylistAlertController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKAlertController.h"
#import "MEKPlaylistActionProtocol.h"

@interface MEKPlaylistAlertController : MEKAlertController

@property (nonatomic, weak) id<MEKPlaylistActionProtocol> delegate;

- (void)showCreatePlaylistDialog;
- (void)showRenameDialogForPlaylist: (PlaylistMO *)playlist;
- (void)showRemoveDialogForPlaylist: (PlaylistMO *)playlist;

@end
