//
//  ViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "ViewController.h"
#import "NetworkService.h"
#import "YouTubeParser.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "MEKPlayerViewController.h"

@import AVFoundation;
@import AVKit;
@import AssetsLibrary;
@import MediaPlayer;

@interface ViewController ()

@property (nonatomic, strong) MEKPlayerViewController *playerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    NSDictionary *urls = [YouTubeParser getYouTubeVideoUrls:@"https://www.youtube.com/watch?v=4BltTurluAg"];

    self.playerController = [MEKPlayerViewController new];
    self.playerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
    self.playerController.player = [AVPlayer playerWithURL:urls[@"360p"]];
    
    UIImage *artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", @"4BltTurluAg"]]]];

    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:artworkImage.size requestHandler:^UIImage * _Nonnull(CGSize size) {
        return artworkImage;
    }];
    
    self.playerController.playingInfo = @{MPMediaItemPropertyTitle : @"Title",
                                          MPMediaItemPropertyArtist : @"Artist",
                                          MPMediaItemPropertyArtwork : albumArt};
    
    //AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:urls[@"360p"]];
    [self.playerController.player play];
    
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
}
//
//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
////    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
////    [self becomeFirstResponder];
//
//    //[self playPlayer];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    //[self pausePlayer];
//    [super viewWillDisappear:animated];
////    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
////    [self resignFirstResponder];
//}

//-(void) playPlayer
//{
//    [self.player play];
//}
//
//-(void) pausePlayer
//{
//    [self.player pause];
//}

@end
