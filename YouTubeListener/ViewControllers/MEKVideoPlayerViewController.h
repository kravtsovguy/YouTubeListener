//
//  MEKVideoPlayerViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItemMO+CoreDataClass.h"
#import "PlaylistMO+CoreDataClass.h"
#import "YouTubeParser.h"
#import "VideoItemDelegate.h"

@protocol MEKVideoPlayerViewControllerDelegate <NSObject>

@optional
- (void)videoPlayerViewControllerClosed;

@end

@interface MEKVideoPlayerViewController : UIViewController

@property (nonatomic, weak) id<MEKVideoPlayerViewControllerDelegate> playerDelegate;
@property (nonatomic, weak) id<MEKVideoItemDelegate> delegate;

@property (nonatomic, readonly) VideoItemMO *currentItem;

- (instancetype)initWithVideoItem: (VideoItemMO*) item;

- (void)minimizeWithDuration: (NSTimeInterval) duration withHeight: (CGFloat) height;
- (void)maximizeWithDuration: (NSTimeInterval) duration;
- (void)setDownloadingProgress: (double) progress;

@end

