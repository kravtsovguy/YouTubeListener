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

@protocol MEKVideoItemActionProtocol <NSObject>

@optional

- (void)videoItemPlay: (VideoItemMO *)item;
- (void)videoItemPlayURL: (NSURL *)url;

- (void)videoItemAddToLibrary: (VideoItemMO *) item;
- (void)videoItemRemoveFromLibrary: (VideoItemMO *) item;

- (void)videoItem: (VideoItemMO *)item downloadWithQuality: (VideoItemQuality)quality;
- (void)videoItemCancelDownload: (VideoItemMO *)item;
- (void)videoItemRemoveDownload: (VideoItemMO *)item;

- (void)videoItemOpenURL: (VideoItemMO *)item;

- (void)videoItemRemoveAll;

@end
