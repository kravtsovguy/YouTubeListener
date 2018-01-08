//
//  MEKPlayerViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 13/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@import AVFoundation;
@import AVKit;
@import MediaPlayer;

@interface MEKPlayerViewController ()

@end

@implementation MEKPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.updatesNowPlayingInfoCenter = NO;
    
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    [[rcc skipBackwardCommand] setEnabled:NO];
    [[rcc skipForwardCommand] setEnabled:NO];
    
    [rcc.changePlaybackPositionCommand addTarget:self action:@selector(changedThumbSliderOnLockScreen:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieStateChange)
                                                 name:AVPlayerItemTimeJumpedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieStateChange)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self updateControlCenter];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self becomeFirstResponder];
    });
}

-(void)setPlayingInfo:(NSDictionary *)playingInfo
{
    _playingInfo = playingInfo;
    [self updateControlCenter];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (self.player.rate == 0)
        return;
    
    AVPlayer *tempPlayer = self.player;
    self.player = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.player = tempPlayer;
    });
    //[self.mPlayer performSelector:@selector(play) withObject:nil afterDelay:0.02];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            if([self.player rate] == 0){
                [self.player play];
            } else {
                [self.player pause];
            }
            break;
        case UIEventSubtypeRemoteControlPlay:
            [self.player play];
            break;
        case UIEventSubtypeRemoteControlPause:
            [self.player pause];
            break;
        default:
            break;
    }
    
    [self updateControlCenter];
}

- (MPRemoteCommandHandlerStatus)changedThumbSliderOnLockScreen:(MPChangePlaybackPositionCommandEvent *)event
{
    CMTime time = CMTimeMakeWithSeconds(event.positionTime, self.player.currentItem.asset.duration.timescale);
    [self.player seekToTime:time];
    
    [self updateControlCenter];
    
    return MPRemoteCommandHandlerStatusSuccess;
}

- (void)movieStateChange{
    [self updateControlCenter];
}

- (void)updateControlCenter
{
    NSMutableDictionary *playingInfo = [[NSMutableDictionary alloc] initWithDictionary:self.playingInfo ?: [NSDictionary new]];
    
    if (self.player)
    {
        playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = @(self.player.rate);
        playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(CMTimeGetSeconds(self.player.currentItem.currentTime));
        playingInfo[MPMediaItemPropertyPlaybackDuration] = @(CMTimeGetSeconds(self.player.currentItem.asset.duration));
    }
    
    MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo = playingInfo;
}

@end
