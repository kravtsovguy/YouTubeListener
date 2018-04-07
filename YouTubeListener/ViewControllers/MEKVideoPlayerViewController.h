//
//  MEKVideoPlayerViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEKPropertyDownloadControllerProtocol.h"
#import "MEKPropertyManagedObjectContextProtocol.h"

@class VideoItemMO;

extern CGFloat const MEKPlayerViewHeightSizeMaximized;
extern CGFloat const MEKPlayerViewHeightSizeMinimized;

@protocol MEKVideoPlayerViewControllerDelegate <NSObject>

@optional
- (void)videoPlayerViewControllerClosed;
- (void)videoPlayerViewControllerOpen;

@end

@interface MEKVideoPlayerViewController : UIViewController <MEKPropertyDownloadControllerProtocol, MEKPropertyManagedObjectContextProtocol>

@property (nonatomic, weak) id<MEKVideoPlayerViewControllerDelegate> delegate;

- (instancetype)initWithVideoItem: (VideoItemMO*) item;
- (void)minimizeWithDuration: (NSTimeInterval) duration;
- (void)maximizeWithDuration: (NSTimeInterval) duration;

@end

