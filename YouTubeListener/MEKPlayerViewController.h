//
//  MEKPlayerViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 13/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface MEKPlayerViewController : AVPlayerViewController

@property (nonatomic, strong) NSDictionary *playingInfo;

@end
