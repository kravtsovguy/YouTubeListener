//
//  MEKPlayerController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 06/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistMO+CoreDataClass.h"
#import "VideoItemMO+CoreDataClass.h"
#import "MEKDownloadController.h"

typedef NS_ENUM (NSInteger, MEKPlayerVisibleState) {
    MEKPlayerVisibleStateNone = 0,
    MEKPlayerVisibleStateMinimized = 1,
    MEKPlayerVisibleStateMaximized = 2,
};

@interface MEKPlayerController : NSObject

@property (nonatomic, readonly) BOOL isOpened;
@property (nonatomic, readonly) MEKPlayerVisibleState visibleState;
@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;

- (void)openVideoItem: (VideoItemMO*) item;
- (void)openVideoItem: (VideoItemMO*) item withVisibleState:(MEKPlayerVisibleState) state;

- (void)openURL: (NSURL*) videoURL;
- (void)openURL: (NSURL*) videoURL withVisibleState:(MEKPlayerVisibleState) state;

- (void)close;
- (void)minimize;
- (void)maximize;

@end
