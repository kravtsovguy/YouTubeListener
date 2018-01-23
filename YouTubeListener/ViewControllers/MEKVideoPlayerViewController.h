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
#import "MEKVideoItemDownloadController.h"

static const CGFloat MEKPlayerViewHeightSizeMaximized = 320;
static const CGFloat MEKPlayerViewHeightSizeMinimized = 60;

@protocol MEKVideoPlayerViewControllerDelegate <NSObject>

@optional
- (void)videoPlayerViewControllerClosed;
- (void)videoPlayerViewControllerOpen;

@end

@interface MEKVideoPlayerViewController : UIViewController

@property (nonatomic, weak) id<MEKVideoPlayerViewControllerDelegate> delegate;
@property (nonatomic, readonly) MEKVideoItemDownloadController *downloadController;

- (instancetype)initWithVideoItem: (VideoItemMO*) item;

- (void)minimizeWithDuration: (NSTimeInterval) duration;
- (void)maximizeWithDuration: (NSTimeInterval) duration;

@end

