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

@protocol MEKVideoPlayerViewControllerDelegate <NSObject>

@optional
- (void)videoPlayerViewControllerClosed;
- (void)videoPlayerViewControllerAddVideoItem: (VideoItemMO*) item toPlaylist: (PlaylistMO*) playlist;
- (void)videoPlayerViewControllerDownloadVideoItem: (VideoItemMO*) item withQuality: (YouTubeParserVideoQuality) quality;

@end

@interface MEKVideoPlayerViewController : UIViewController

@property (nonatomic, weak) id<MEKVideoPlayerViewControllerDelegate> delegate;

- (instancetype)initWithURL: (NSURL*) url;
-(void) minimizeWithDuration: (NSTimeInterval) duration withHeight: (CGFloat) height;
-(void) maximizeWithDuration: (NSTimeInterval) duration;

@end

