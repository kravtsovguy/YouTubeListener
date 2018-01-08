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

@import AVFoundation;
@import AVKit;
@import AssetsLibrary;
@import MediaPlayer;

@interface MEKVideoPlayerViewController () <YouTubeParserDelegate, NetworkServiceOutputProtocol>

@property (nonatomic, strong) MEKPlayerViewController *playerController;
@property (nonatomic, strong) MEKProgressBar *progressBar;
@property (nonatomic, strong) YouTubeParser *ytb;
@property (nonatomic, strong) NetworkService *networkService;
@property (nonatomic, strong) NSURLSessionDownloadTask *imageTask;
@property (nonatomic, strong) NSURLSessionDownloadTask *videoTask;
@property (nonatomic, strong) NSDictionary *videoInfo;

@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) MEKDowloadButton *downloadButton;

@property (nonatomic, assign) BOOL maximized;

@end

@implementation MEKVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.view setFrame:CGRectMake(5, 0, self.view.frame.size.width - 10, 400)];
    
    self.maximized = YES;
    
    self.titleLabel = [UILabel new];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    [self.view addSubview:self.titleLabel];
    
    self.authorLabel = [UILabel new];
    self.authorLabel.numberOfLines = 1;
    self.authorLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];//[UIFont fontWithName:@"Helvetica-Semibold" size:17];
    [self.view addSubview:self.authorLabel];
    
    self.closeButton = [UIButton new];
    [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    self.closeButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.view addSubview:self.closeButton];
    
    self.addButton = [UIButton new];
    //self.addButton.backgroundColor = UIColor.blueColor;
    [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    self.addButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.view addSubview:self.addButton];
    
    self.downloadButton = [[MEKDowloadButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //self.downloadButton.backgroundColor = UIColor.blueColor;
    self.downloadButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.downloadButton addTarget:self action:@selector(downloadPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
    
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.view.layer.borderWidth = 0.5;
    
    self.networkService = [NetworkService new];
    [self.networkService configurateUrlSessionWithParams:nil];
    self.networkService.output = self;
    
    self.ytb = [YouTubeParser new];
    self.ytb.delegate = self;
    
   // NSString *latest = @"";//@"https://www.youtube.com/watch?v=IVGfrkcqh4g";@"https://www.youtube.com/watch?v=1ALScePc9Go";[UIPasteboard generalPasteboard].string;
    NSString *url = @"https://www.youtube.com/watch?v=IVGfrkcqh4g";//@"https://www.youtube.com/watch?v=4BltTurluAg";
    
//    NSString *latest = [UIPasteboard generalPasteboard].string;
//    if (latest.length > 0)
//        url = latest;
//    
    [self.ytb loadVideoInfo:url];
    
    self.playerController = [MEKPlayerViewController new];
    //self.playerController.view.backgroundColor = UIColor.clearColor;
    //self.playerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);

    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
    
    self.videoWidth = CGRectGetWidth(self.view.frame);
    self.videoHeight = self.videoWidth * 9 / 16;
    
//    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.mas_top);
//        make.left.equalTo(self.view.mas_left);
//        self.videoWidthConstraint = make.width.equalTo(self.view.mas_width);
//        self.videoHeightConstraint = make.height.equalTo(@300);
//    }];
    
    //self.progressBar = [[MEKProgressBar alloc] initWithFrame:CGRectMake(20, 400, 50, 50)];
    //[self.view addSubview:self.progressBar];


//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"movie.mp4"];
//    NSURL* urlMovie = [NSURL fileURLWithPath:dataPath];
//
//    //NSData *nsdata = [NSData dataWithContentsOfFile:dataPath options:NSDataReadingMappedIfSafe error:nil];
//    self.playerController.player = [AVPlayer playerWithURL:urlMovie];
//    [self.playerController.player play];
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
            make.top.equalTo(self.view.mas_top).with.offset(20);
            make.right.equalTo(self.view.mas_right).with.offset(20);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }
        else
        {
            make.top.equalTo(self.view.mas_top).with.offset(20);
            make.right.equalTo(self.view.mas_right).with.offset(-20);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
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
        if (self.maximized)
        {
            make.right.equalTo(self.view.mas_right).with.offset(-20);
        }
        else
        {
            make.right.equalTo(self.view.mas_right).with.offset(100);
        }
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];

    [super updateViewConstraints];
}


-(void)maximize
{
    self.maximized = YES;
    
    self.videoWidth = CGRectGetWidth(self.view.frame);
    self.videoHeight = self.videoWidth * 9 / 16;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        self.view.backgroundColor = UIColor.whiteColor;
        self.blurEffectView.alpha = 0;
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        self.titleLabel.numberOfLines = 0;
        
        self.authorLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        //self.authorLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    } completion:nil];
}

-(void)minimizeWithHeight:(CGFloat)height
{
    self.maximized = NO;
    
    self.videoWidth = height * 16 / 9;
    self.videoHeight = height;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    
    if (!self.blurEffectView)
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurEffectView = blurEffectView;
        blurEffectView.alpha = 0;
        blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        blurEffectView.frame = self.view.bounds;
        //blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:blurEffectView atIndex:0];
        //[self.view addSubview:blurEffectView];
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        self.view.backgroundColor = UIColor.clearColor;
        self.blurEffectView.alpha = 1;
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
        self.titleLabel.numberOfLines = 1;
        
        self.authorLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:11];
    } completion:nil];
}

-(void) downloadPressed:(UIButton *)button
{
    self.downloadButton.isLoading = YES;
    self.videoTask = [self.networkService loadDataFromURL:self.videoInfo[@"urls"][@(YouTubeParserVideoQualitySmall144)]];
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

- (void)infoDidLoad:(NSDictionary *)info forVideo:(NSString *)videoId {
    
    self.videoInfo = info;
    
    self.titleLabel.text = self.videoInfo[@"title"];
    self.authorLabel.text = self.videoInfo[@"author"];
    
    self.playerController.playingInfo = @{MPMediaItemPropertyTitle : self.videoInfo[@"title"],
                                          MPMediaItemPropertyArtist : self.videoInfo[@"author"]
                                          };
    
    self.playerController.player = [AVPlayer playerWithURL:self.videoInfo[@"urls"][@(YouTubeParserVideoQualityHD720)]];
    self.playerController.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    [self.playerController.player play];
    
    self.imageTask = [self.networkService loadDataFromURL:self.videoInfo[@"thumbnail_small"]];
    
    //self.videoTask = [self.networkService loadDataFromURL:self.videoInfo[@"urls"][@(YouTubeParserVideoQualitySmall144)]];
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
