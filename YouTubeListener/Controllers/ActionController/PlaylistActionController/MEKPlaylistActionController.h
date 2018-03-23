//
//  MEKPlaylistActionController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKActionController.h"
#import "MEKPlaylistActionProtocol.h"

@class MEKVideoItemActionController;

@interface MEKPlaylistActionController : MEKActionController <MEKPlaylistActionProtocol>

@property (nonatomic, weak) id<MEKPlaylistActionProtocol> delegate;
@property (nonatomic, weak) MEKVideoItemActionController *videoItemActionController;

@end
