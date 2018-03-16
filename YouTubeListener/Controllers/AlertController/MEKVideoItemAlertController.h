//
//  MEKVideoItemAlertController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 08/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKAlertController.h"
#import "MEKVideoItemActionProtocol.h"

@interface MEKVideoItemAlertController : MEKAlertController

@property (nonatomic, weak) id<MEKVideoItemActionProtocol> delegate;

- (void)showActionsForVideoItem: (VideoItemMO *)item;
- (void)showPlaylistSelectionForVideoItem:(VideoItemMO *)item;
- (void)showDownloadingDialogForVideoItem: (VideoItemMO*)item;

@end
