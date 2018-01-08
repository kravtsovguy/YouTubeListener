//
//  MEKVideoPlayerViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEKVideoPlayerViewController : UIViewController

@property (nonatomic, strong) NSURL *currentURL;

-(void) minimizeWithHeight: (CGFloat) height;
-(void) maximize;

@end

