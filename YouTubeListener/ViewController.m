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

@import AVFoundation;
@import AVKit;
@import AssetsLibrary;
@import MediaPlayer;

@interface ViewController () <NetworkServiceOutputProtocol>

@property (nonatomic, strong) NetworkService *networkService;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerViewController *playerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *urls = [YouTubeParser getYouTubeVideoUrls:@"https://www.youtube.com/watch?v=4BltTurluAg"];

    //AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:urls[@"360p"]];
    self.player = [AVPlayer playerWithURL:urls[@"360p"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    AVPlayerViewController *controller = [AVPlayerViewController new];
    self.playerController = controller;
    controller.updatesNowPlayingInfoCenter = NO;
    controller.player = self.player;
    [self playPlayer];

    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    controller.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
    
    self.view.backgroundColor = UIColor.whiteColor;
    
//    NSArray *keys = [NSArray arrayWithObjects:
//                     MPMediaItemPropertyTitle,
//                     MPMediaItemPropertyArtist,
//                     nil];
//
//    NSArray *values = [NSArray arrayWithObjects:
//                       @"DIL vali gal",
//                       @"ammy virk",
//                       nil];
//    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
//
//
//    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{MPMediaItemPropertyTitle : @"1", MPMediaItemPropertyArtist : @"2"};
    
    [self updateControlCenter];
    
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPSkipIntervalCommand *skipBackwardIntervalCommand = [rcc skipBackwardCommand];
    [skipBackwardIntervalCommand setEnabled:NO];
    
    MPSkipIntervalCommand *skipForwardIntervalCommand = [rcc skipForwardCommand];
    [skipForwardIntervalCommand setEnabled:NO];
    
    [rcc.changePlaybackPositionCommand addTarget:self action:@selector(changedThumbSliderOnLockScreen:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieStateChange)
                                                 name:AVPlayerItemTimeJumpedNotification
     
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieStateChange)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
     
                                               object:nil];
}

- (void)movieStateChange{
    [self updateControlCenter];
}

- (void)updateControlCenter{
    
    //NSNumber *ct = @(CMTimeGetSeconds(self.player.currentItem.currentTime));
    //NSLog(@"%@", ct);
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];

    NSMutableDictionary *songInfo = [NSMutableDictionary new];
    
    [songInfo setObject:@"1" forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:@"3" forKey:MPMediaItemPropertyArtist];
    //[songInfo setObject:@2 forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [songInfo setObject:@(CMTimeGetSeconds(self.player.currentItem.asset.duration)) forKey:MPMediaItemPropertyPlaybackDuration];
    [songInfo setObject:@(self.player.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    //[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
    
    //NSMutableDictionary *nowPlayingInfo = [playingInfoCenter.nowPlayingInfo mutableCopy];
    [songInfo setObject:@(CMTimeGetSeconds(self.player.currentItem.currentTime)) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    playingInfoCenter.nowPlayingInfo = songInfo;
}

- (MPRemoteCommandHandlerStatus)changedThumbSliderOnLockScreen:(MPChangePlaybackPositionCommandEvent *)event
{
    NSLog(@"%f", event.positionTime);
    
    int32_t timeScale = self.player.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(event.positionTime, timeScale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self updateControlCenter];
    
    return MPRemoteCommandHandlerStatusSuccess;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];
    
    //[self playPlayer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self pausePlayer];
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//    [self resignFirstResponder];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            if([self.player rate] == 0){
                [self playPlayer];
            } else {
                [self pausePlayer];
            }
            break;
        case UIEventSubtypeRemoteControlPlay:
            [self playPlayer];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self pausePlayer];
            break;
        default:
            break;
    }
    
    [self updateControlCenter];
}

-(void) playPlayer
{
    [self.player play];
}

-(void) pausePlayer
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self.player pause];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (self.player.rate == 0)
        return;
    
    self.playerController.player = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.playerController.player = self.player;
    });
    //[self.mPlayer performSelector:@selector(play) withObject:nil afterDelay:0.02];
}

@end
