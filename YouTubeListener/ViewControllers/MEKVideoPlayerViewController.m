//
//  MEKVideoPlayerViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoPlayerViewController.h"
#import "NetworkService.h"
#import "YouTubeParser.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "MEKPlayerViewController.h"
#import "MEKDowloadButton.h"
#import <Masonry/Masonry.h>
#import "MEKPlaylistsViewController.h"

@import AVFoundation;
@import AVKit;
@import AssetsLibrary;
@import MediaPlayer;

@interface MEKVideoPlayerViewController () <YouTubeParserDelegate, NetworkServiceOutputProtocol, MEKPlaylistsViewControllerDelegate>

@property (nonatomic, strong) MEKPlayerViewController *playerController;
@property (nonatomic, strong) MEKProgressBar *progressBar;
@property (nonatomic, strong) YouTubeParser *ytb;
@property (nonatomic, strong) NetworkService *networkService;
@property (nonatomic, strong) NSURLSessionDownloadTask *imageTask;
@property (nonatomic, strong) NSURLSessionDownloadTask *videoTask;
@property (nonatomic, strong) VideoItemMO *videoInfo;

@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) MEKDowloadButton *downloadButton;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) BOOL maximized;

@end

@implementation MEKVideoPlayerViewController

- (instancetype)init
{
    return [self initWithURL:[NSURL URLWithString:@"https://www.youtube.com/watch?v=rNhfrFASCGE"]];
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
        [self maximizeWithDuration:0];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    [self.view addSubview:self.titleLabel];
    
    self.authorLabel = [UILabel new];
    self.authorLabel.numberOfLines = 1;
    self.authorLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [self.view addSubview:self.authorLabel];
    
    self.closeButton = [UIButton new];
    [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    self.closeButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    self.addButton = [UIButton new];
    //self.addButton.backgroundColor = UIColor.blueColor;
    [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    self.addButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
    self.downloadButton = [[MEKDowloadButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //self.downloadButton.backgroundColor = UIColor.blueColor;
    self.downloadButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
    

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.alpha = 0;
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    //self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.blurEffectView atIndex:0];
    
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.view.layer.borderWidth = 0.5;
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = YES;
    
    self.networkService = [NetworkService new];
    [self.networkService configurateUrlSessionWithParams:nil];
    self.networkService.output = self;
    
    self.ytb = [YouTubeParser new];
    self.ytb.delegate = self;
    
    [self.ytb loadVideoInfo:self.url.absoluteString];
    
    self.playerController = [MEKPlayerViewController new];
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
}

- (void)addButtonPressed:(UIButton *)button
{
    MEKPlaylistsViewController *playlistsController = [[MEKPlaylistsViewController alloc] initModal];
    playlistsController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

-(void)downloadButtonPressed:(UIButton *)button
{
    self.downloadButton.isLoading = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayerViewControllerDownloadVideoItem:withQuality:)])
    {
        [self.delegate videoPlayerViewControllerDownloadVideoItem:self.videoInfo withQuality:YouTubeParserVideoQualitySmall144];
    }
    //self.videoTask = [self.networkService loadDataFromURL:self.videoInfo.urls[@(YouTubeParserVideoQualitySmall144)]];
}

- (void)closeButtonPressed: (UIButton*) button
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerViewControllerClosed)])
    {
        [self.delegate videoPlayerViewControllerClosed];
    }
}

-(void)playlistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerViewControllerAddVideoItem:toPlaylist:)])
    {
        [self.delegate videoPlayerViewControllerAddVideoItem:self.videoInfo toPlaylist:playlist];
    }
}

- (void)updateViewConstraints {
    [self.playerController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(@(self.videoWidth));
        make.height.equalTo(@(self.videoHeight));
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.maximized)
        {
            make.top.equalTo(self.playerController.view.mas_bottom).with.offset(10);
            make.left.equalTo(self.view.mas_left).with.offset(10);
            make.right.equalTo(self.view.mas_right).with.offset(-10);
        }
        else
        {
            make.top.equalTo(self.view.mas_top).with.offset(10);
            make.left.equalTo(self.playerController.view.mas_right).with.offset(10);
            make.right.equalTo(self.view.mas_right).with.offset(-50);
        }
    }];
    
    [self.authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.maximized)
        {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(10);
            make.left.equalTo(self.view.mas_left).with.offset(10);
            make.right.equalTo(self.view.mas_right).with.offset(-10);
        }
        else
        {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(10);
            make.left.equalTo(self.playerController.view.mas_right).with.offset(10);
            make.right.equalTo(self.view.mas_right).with.offset(-30);
        }
    }];
    
    [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.maximized)
        {
            make.top.equalTo(self.view.mas_top).with.offset(0);
            make.right.equalTo(self.view.mas_right).with.offset(60);
            make.width.equalTo(@60);
            make.height.equalTo(@60);
        }
        else
        {
            make.top.equalTo(self.view.mas_top).with.offset(0);
            make.right.equalTo(self.view.mas_right).with.offset(0);
            make.width.equalTo(@60);
            make.height.equalTo(@60);
        }
    }];
    
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(5);
        make.right.equalTo(self.downloadButton.mas_left).with.offset(-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.downloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(5);
        make.right.equalTo(self.view.mas_right).with.offset(self.maximized ? -20 : 100);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];

    [super updateViewConstraints];
}

- (void)maximizeUI
{
    self.view.layer.cornerRadius = 10;
    self.view.backgroundColor = UIColor.whiteColor;
    self.blurEffectView.alpha = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    self.titleLabel.numberOfLines = 0;
    
    self.authorLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
}

- (void)minimizeUI
{
    self.view.layer.cornerRadius = 0;
    self.view.backgroundColor = UIColor.clearColor;
    self.blurEffectView.alpha = 1;
    self.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    self.titleLabel.numberOfLines = 1;
    
    self.authorLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightLight];
}


- (void)maximizeWithDuration:(NSTimeInterval)duration
{
    self.maximized = YES;
    
    self.videoWidth = CGRectGetWidth(self.view.frame);
    self.videoHeight = self.videoWidth * 9 / 16;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self maximizeUI];
    } completion:nil];
}

- (void)minimizeWithDuration:(NSTimeInterval)duration withHeight:(CGFloat)height
{
    self.maximized = NO;
    
    self.videoWidth = height * 16 / 9;
    self.videoHeight = height;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self minimizeUI];
    } completion:nil];
}



-(void)loadingIsDoneWithDataRecieved:(NSData *)dataRecieved withTask:(NSURLSessionDownloadTask *)task withService:(id<NetworkServiceInputProtocol>)service
{
    if (task == self.imageTask)
    {
        UIImage *artworkImage = [UIImage imageWithData:dataRecieved];
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:artworkImage.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return artworkImage;
        }];

        self.playerController.playingInfo = @{MPMediaItemPropertyTitle : self.videoInfo.title,
                                              MPMediaItemPropertyArtist : self.videoInfo.author,
                                              MPMediaItemPropertyArtwork : albumArt
                                              };
    }
    
    if (task == self.videoTask)
    {
        // Use GCD's background queue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // Generate the file path
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"movie.mp4"];
            
            // Save it into file system
            [dataRecieved writeToFile:dataPath atomically:YES];
        });
    }
    
    
}

-(void)loadingContinuesWithProgress:(double)progress withTask:(NSURLSessionDownloadTask *)task withService:(id<NetworkServiceInputProtocol>)service
{
    if (task == self.videoTask)
    {
        NSLog(@"progress: %f", progress);
        self.downloadButton.progressBar.progress = progress;
    }
}

- (void)infoDidLoad:(VideoItemMO *)info forVideo:(NSString *)videoId
{
    self.videoInfo = info;
    
    self.titleLabel.text = self.videoInfo.title;
    self.authorLabel.text = self.videoInfo.author;
    
    self.playerController.playingInfo = @{MPMediaItemPropertyTitle : self.videoInfo.title,
                                          MPMediaItemPropertyArtist : self.videoInfo.author
                                          };
    
    self.playerController.player = [AVPlayer playerWithURL:self.videoInfo.urls[@(YouTubeParserVideoQualityHD720)]];
    self.playerController.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    [self.playerController.player play];
    
    self.imageTask = [self.networkService loadDataFromURL:self.videoInfo.thumbnailSmall];
    
    //self.videoTask = [self.networkService loadDataFromURL:self.videoInfo[@"urls"][@(YouTubeParserVideoQualitySmall144)]];
    
    if ([self.delegate respondsToSelector:@selector(videoPlayerViewControllerAddVideoItem:toPlaylist:)])
    {
        [self.delegate videoPlayerViewControllerAddVideoItem:self.videoInfo toPlaylist:nil];
    }
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [self.view setNeedsUpdateConstraints];
//}

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
