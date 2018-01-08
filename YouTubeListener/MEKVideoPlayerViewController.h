//
//  MEKVideoPlayerViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEKVideoPlayerViewControllerDelegate <NSObject>

@optional
- (void)videoPlayerViewControllerClosed;

@end

@interface MEKVideoPlayerViewController : UIViewController

@property (nonatomic, weak) id<MEKVideoPlayerViewControllerDelegate> delegate;

- (instancetype)initWithURL: (NSURL*) url;
-(void) minimizeWithDuration: (NSTimeInterval) duration withHeight: (CGFloat) height;
-(void) maximizeWithDuration: (NSTimeInterval) duration;

@end

