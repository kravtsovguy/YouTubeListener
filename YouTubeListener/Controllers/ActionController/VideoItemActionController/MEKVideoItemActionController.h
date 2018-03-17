//
//  MEKVideoItemActionController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 07/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKActionController.h"
#import "MEKVideoItemActionProtocol.h"

@class MEKPlaylistActionController;

@interface MEKVideoItemActionController : MEKActionController <MEKVideoItemActionProtocol>

@property (nonatomic, weak) id<MEKVideoItemActionProtocol> delegate;
@property (nonatomic, strong) MEKPlaylistActionController *playlistActionController;

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end
