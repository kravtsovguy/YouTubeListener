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

@interface ViewController () <YouTubeParserDelegate, NetworkServiceOutputProtocol>

@property (nonatomic, strong) MEKPlayerViewController *playerController;
@property (nonatomic, strong) YouTubeParser *ytb;
@property (nonatomic, strong) NetworkService *networkService;
@property (nonatomic, strong) NSURLSessionDownloadTask *imageTask;
@property (nonatomic, strong) NSDictionary *videoInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.networkService = [NetworkService new];
    [self.networkService configurateUrlSessionWithParams:nil];
    self.networkService.output = self;
    
    self.ytb = [YouTubeParser new];
    self.ytb.delegate = self;
    
   // NSString *latest = @"";//@"https://www.youtube.com/watch?v=IVGfrkcqh4g";@"https://www.youtube.com/watch?v=1ALScePc9Go";[UIPasteboard generalPasteboard].string;
    NSString *url = @"https://www.youtube.com/watch?v=IVGfrkcqh4g";//@"https://www.youtube.com/watch?v=4BltTurluAg";
    
    NSString *latest = [UIPasteboard generalPasteboard].string;
    if (latest.length > 0)
        url = latest;
    
    [self.ytb loadVideoInfo:url];
    
    self.playerController = [MEKPlayerViewController new];
    self.playerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);

    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
}

-(void)loadingIsDoneWithDataRecieved:(NSData *)dataRecieved withTask:(NSURLSessionDownloadTask *)task withService:(id<NetworkServiceInputProtocol>)service
{
    if (task == self.imageTask)
    {
        UIImage *artworkImage = [UIImage imageWithData:dataRecieved];
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:artworkImage.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return artworkImage;
        }];

        self.playerController.playingInfo = @{MPMediaItemPropertyTitle : self.videoInfo[@"title"],
                                              MPMediaItemPropertyArtist : self.videoInfo[@"author"],
                                              MPMediaItemPropertyArtwork : albumArt
                                              };
    }
    
    
}

-(void)loadingContinuesWithProgress:(double)progress withTask:(NSURLSessionDownloadTask *)task withService:(id<NetworkServiceInputProtocol>)service
{
    NSLog(@"progress: %f", progress);
}

- (void)infoDidLoad:(NSDictionary *)info forVideo:(NSString *)videoId {
    
    self.videoInfo = info;
    
    self.playerController.playingInfo = @{MPMediaItemPropertyTitle : self.videoInfo[@"title"],
                                          MPMediaItemPropertyArtist : self.videoInfo[@"author"]
                                          };
    
    self.playerController.player = [AVPlayer playerWithURL:self.videoInfo[@"urls"][@(YouTubeParserVideoQualityHD720)]];
    [self.playerController.player play];
    
    self.imageTask = [self.networkService loadDataFromURL:self.videoInfo[@"thumbnail_small"]];
    
    //[self.networkService loadDataFromURL:self.videoInfo[@"urls"][@(YouTubeParserVideoQualitySmall144)]];
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

@end
