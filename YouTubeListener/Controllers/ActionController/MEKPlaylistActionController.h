//
//  MEKPlaylistActionController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEKActionController.h"
#import "MEKPlaylistActionProtocol.h"

@interface MEKPlaylistActionController : MEKActionController <MEKPlaylistActionProtocol>

@property (nonatomic, weak) id<MEKPlaylistActionProtocol> delegate;

@end
