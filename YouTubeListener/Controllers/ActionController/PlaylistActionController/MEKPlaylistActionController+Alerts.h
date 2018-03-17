//
//  MEKPlaylistActionController+Alerts.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistActionController.h"
#import "MEKAlertController.h"

@interface MEKPlaylistActionController (Alerts)

- (void)showCreatePlaylistDialog;
- (void)showRenamePlaylistDialog:(PlaylistMO *)playlist;
- (void)showRemovePlaylistDialog:(PlaylistMO *)playlist;
- (void)showChoosePlaylistDialogForVideoItem:(VideoItemMO *)item;

@end
