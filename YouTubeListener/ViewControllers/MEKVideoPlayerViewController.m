//
//  MEKVideoPlayerViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoPlayerViewController.h"
#import "MEKYouTubeVideoParser.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "MEKPlayerViewController.h"
#import "MEKDowloadButton.h"
#import <Masonry/Masonry.h>
#import "MEKModalPlaylistsViewController.h"
#import "UIImage+Cache.h"

@import AVFoundation;
@import AVKit;
@import AssetsLibrary;
@import MediaPlayer;

@interface MEKVideoPlayerViewController () <MEKWebVideoParserOutputProtocol, MEKModalPlaylistsViewControllerDelegate>

@property (nonatomic, strong) MEKPlayerViewController *playerController;
@property (nonatomic, strong) MEKProgressBar *progressBar;
@property (nonatomic, strong) MEKWebVideoParser *youtubeParser;

@property (nonatomic, strong) VideoItemMO *item;
@property (nonatomic, assign) BOOL maximized;

@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) MEKDowloadButton *downloadButton;

@end

@implementation MEKVideoPlayerViewController

- (instancetype)initWithVideoItem:(VideoItemMO *)item
{
    self = [super init];
    if (self) {
        _item = item;
        [self maximizeWithDuration:0];
    }
    return self;
}

- (void)viewDidLoad
{
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
    
    self.playerController = [MEKPlayerViewController new];
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];

    if (self.item.added)
    {
        self.item.added = [NSDate new];
        [self.item saveObject];
    }
    
    [self setWithVideoItem:self.item];
    
    if (!self.item.downloadedURLs)
    {
        self.youtubeParser = [MEKYouTubeVideoParser new];
        self.youtubeParser.output = self;
        [self.youtubeParser loadVideoItem:self.item];;
    }
}

- (void)addButtonPressed:(UIButton *)button
{
    MEKModalPlaylistsViewController *playlistsController = [MEKModalPlaylistsViewController new];
    playlistsController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)downloadButtonPressed:(UIButton *)button
{
    if (!self.downloadButton.isLoading)
    {
        self.downloadButton.loading = YES;
        if ([self.delegate respondsToSelector:@selector(videoItemDownload:withQuality:)])
        {
            [self.delegate videoItemDownload:self.currentItem withQuality:VideoItemQualityMedium360];
        }
    }
    else
    {
        self.downloadButton.loading = NO;
        if ([self.delegate respondsToSelector:@selector(videoItemCancelDownload:)])
        {
            [self.delegate videoItemCancelDownload:self.currentItem];
        }
    }
}

- (void)closeButtonPressed: (UIButton*) button
{
    if ([self.playerDelegate respondsToSelector:@selector(videoPlayerViewControllerClosed)])
    {
        [self.playerDelegate videoPlayerViewControllerClosed];
    }
}

- (void)modalPlaylistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist
{
    if ([self.delegate respondsToSelector:@selector(videoItemAddToPlaylist:playlist:)])
    {
        [self.delegate videoItemAddToPlaylist:self.item playlist:playlist];
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

- (void)setWithVideoItem: (VideoItemMO*) item
{
    if (!item)
    {
        return;
    }
    
    self.item = item;
    
    self.titleLabel.text = self.item.title;
    self.authorLabel.text = self.item.author;
    
    if ([self.item hasDownloaded])
    {
        [self setDownloadingProgress:1];
    }
    
    if (self.item.title && self.item.author)
    {
        self.playerController.playingInfo = @{MPMediaItemPropertyTitle : self.item.title,
                                              MPMediaItemPropertyArtist : self.item.author
                                              };
    }
    
    [UIImage ch_downloadImageFromUrl:self.item.thumbnailSmall completion:^(UIImage *image) {
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return image;
        }];
        
        NSMutableDictionary *playerInfo = self.playerController.playingInfo.mutableCopy;
        playerInfo[MPMediaItemPropertyArtwork] = albumArt;
        
        self.playerController.playingInfo = playerInfo;
    }];
    
    
    NSURL *url =  self.item.downloadedURLs[@(VideoItemQualityMedium360)];
    
    if (!url)
    {
        url = self.item.urls[@(VideoItemQualityHD720)];
    }
    

    if (url && !self.playerController.player)
    {
        self.playerController.player = [AVPlayer playerWithURL:url];
        self.playerController.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        [self.playerController.player play];
    }
}

- (void)webVideoParser:(id<MEKWebVideoParserInputProtocol>)parser didLoadItem:(VideoItemMO *)item
{
    [self setWithVideoItem:item];
}

- (VideoItemMO *)currentItem
{
    return self.item;
}

- (void)setDownloadingProgress:(double)progress
{
    self.downloadButton.progressBar.progress = progress;
    
    if (progress < 1)
    {
        self.downloadButton.loading = progress > 0;
    }
    else
    {
        self.downloadButton.done = YES;
    }
}
@end
