//
//  MEKPlayerController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 06/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoItemMO;

extern NSTimeInterval const MEKPlayerViewAnimationDuration;


typedef NS_ENUM (NSInteger, MEKPlayerVisibleState) {
    MEKPlayerVisibleStateNone = 0,
    MEKPlayerVisibleStateMinimized = 1,
    MEKPlayerVisibleStateMaximized = 2,
};


@interface MEKPlayerController : NSObject

@property (nonatomic, readonly) MEKPlayerVisibleState visibleState;
@property (nonatomic, readonly) BOOL isOpened;

- (void)openVideoItem: (VideoItemMO*) item;
- (void)openVideoItem: (VideoItemMO*) item withVisibleState:(MEKPlayerVisibleState) state;

- (void)close;
- (void)minimize;
- (void)maximize;

@end
