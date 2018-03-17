//
//  MEKCombinedActionController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKActionController.h"
#import "MEKVideoItemActionProtocol.h"
#import "MEKPlaylistActionProtocol.h"

@class MEKAlertController;
@class MEKVideoItemActionController;
@class MEKPlaylistActionController;

@interface MEKCombinedActionController : MEKActionController

@property (nonatomic, strong, readonly) MEKVideoItemActionController *videoItemActionController;
@property (nonatomic, strong, readonly) MEKPlaylistActionController *playlistActionController;

- (void)showClearLibraryDialog;

@end
