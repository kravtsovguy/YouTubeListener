//
//  MEKVideoItemActionProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 07/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VideoItemQuality);

@class VideoItemMO;
@class PlaylistMO;

@protocol MEKVideoItemActionProtocol <NSObject>

@optional

- (void)videoItemShowActions: (VideoItemMO*) item;

- (void)videoItemAddToLibrary: (VideoItemMO*) item;
- (void)videoItemRemoveFromLibrary: (VideoItemMO*) item;

- (void)videoItemAddToPlaylist: (VideoItemMO*) item;
- (void)videoItemRemoveFromPlaylist: (VideoItemMO*) item;

- (void)videoItem: (VideoItemMO*) item addToPlaylist: (PlaylistMO*) playlist;
- (void)videoItem: (VideoItemMO*) item removeFromPlaylist: (PlaylistMO*) playlist;

- (void)videoItemDownload: (VideoItemMO*) item;
- (void)videoItem: (VideoItemMO*) item downloadWithQuality: (VideoItemQuality) quality;
- (void)videoItemCancelDownload: (VideoItemMO*) item;
- (void)videoItemRemoveDownload: (VideoItemMO*) item;

- (void)videoItemOpenURL: (VideoItemMO*) item;

@end
