//
//  VideoItemDelegate.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoItemMO+CoreDataClass.h"
#import "PlaylistMO+CoreDataClass.h"

@protocol MEKVideoItemDelegate <NSObject>

@optional
- (void)videoItemAddToPlaylist: (VideoItemMO*) item;
- (void)videoItemAddToPlaylist: (VideoItemMO*) item playlist: (PlaylistMO*) playlist;
- (void)videoItemDownload: (VideoItemMO*) item;
- (void)videoItemDownload: (VideoItemMO*) item withQuality: (VideoItemQuality) quality;
- (void)videoItemCancelDownload: (VideoItemMO*) item;

@end
