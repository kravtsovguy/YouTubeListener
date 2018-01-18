//
//  MEKVideoPlayerViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoPlayerViewController.h"
#import "MEKWebVideoLoader.h"
#import "MEKPlayerViewController.h"
#import "MEKDowloadButton.h"
#import <Masonry/Masonry.h>
#import "MEKModalPlaylistsViewController.h"
#import "UIImage+Cache.h"
#import "UIViewController+VideoItemActions.h"
#import "AppDelegate.h"


@import MediaPlayer;

static const CGFloat MEKPlayerViewVideoRatio = 16.0f / 9.0f;

@interface MEKVideoPlayerViewController () <MEKWebVideoLoaderOutputProtocol, MEKVideoItemDelegate, MEKDownloadControllerDelegate, MEKModalPlaylistsViewControllerDelegate>

@property (nonatomic, strong) MEKPlayerViewController *playerController;
@property (nonatomic, strong) MEKProgressBar *progressBar;
@property (nonatomic, strong) MEKWebVideoLoader *loader;


@property (nonatomic, strong) VideoItemMO *item;
@property (nonatomic, assign) BOOL maximized;
@property (nonatomic, assign) VideoItemQuality quality;

@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) MEKDowloadButton *downloadButton;
@property (nonatomic, strong) UIButton *qualityButton;
@property (nonatomic, strong) UILabel *downloadInfoLabel;

@end

@implementation MEKVideoPlayerViewController

#pragma mark - init

- (instancetype)initWithVideoItem:(VideoItemMO *)item
{
    self = [super init];
    if (self) {
        _item = item;
        _quality = VideoItemQualityHD720;
        
        if ([_item hasDownloaded])
        {
            _quality = [_item downloadedQuality];
        }
        
        [self maximizeWithDuration:0];
    }
    return self;
}

#pragma mark - Properties

- (MEKDownloadController *)downloadController
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *delegate = ((AppDelegate*)(application.delegate));
    return delegate.downloadController;
}

#pragma mark - UIViewController

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
    
    self.downloadButton = [MEKDowloadButton new];
    //self.downloadButton.backgroundColor = UIColor.blueColor;
    self.downloadButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
    
    self.qualityButton = [UIButton new];
    [self.qualityButton setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
    self.qualityButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.qualityButton addTarget:self action:@selector(qualityButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.qualityButton];
    
    self.downloadInfoLabel = [UILabel new];
    self.downloadInfoLabel.numberOfLines = 1;
    self.downloadInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.downloadInfoLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightUltraLight];
    self.downloadInfoLabel.text = @"";
    [self.view addSubview:self.downloadInfoLabel];
    

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.alpha = 0;
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    //self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.blurEffectView atIndex:0];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:singleTapRecognizer];
    
    self.playerController = [MEKPlayerViewController new];
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.view.layer.borderWidth = 0.5;
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = YES;
    
    self.loader = [MEKWebVideoLoader new];
    self.loader.output = self;

    self.item.added = [NSDate new];
    [self.item saveObject];    
    
    [self setUIwithVideoItem:self.item];
    [self setVideoWithQuality:self.quality];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.downloadController.delegate = self;
    [self setUIwithVideoItem:self.item];
}

- (void)updateViewConstraints
{
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
        make.top.equalTo(self.view.mas_top);
        
        if (self.maximized)
        {
            make.left.equalTo(self.view.mas_right);
        }
        else
        {
            make.right.equalTo(self.view.mas_right);
        }
        
        make.width.equalTo(@(MEKPlayerViewHeightSizeMinimized));
        make.height.equalTo(@(MEKPlayerViewHeightSizeMinimized));
    }];
    
    [self.qualityButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addButton.mas_top);
        make.right.equalTo(self.addButton.mas_left).with.offset(-20);
        //make.left.equalTo(self.view.mas_left).with.offset(10);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.downloadButton.mas_top);
        make.right.equalTo(self.downloadButton.mas_left).with.offset(-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.downloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.maximized)
        {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(5);
        }
        else
        {
            make.top.equalTo(self.playerController.view.mas_bottom).with.offset(10);
        }
        
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.downloadInfoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.downloadButton.mas_top);
        make.left.equalTo(self.downloadButton.mas_right).with.offset(10);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Public

- (void)maximizeWithDuration:(NSTimeInterval)duration
{
    self.maximized = YES;
    
    self.videoWidth = CGRectGetWidth(self.view.frame);
    self.videoHeight = self.videoWidth * (1 / MEKPlayerViewVideoRatio);
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self maximizeUI];
    } completion:nil];
}

- (void)minimizeWithDuration:(NSTimeInterval)duration
{
    self.maximized = NO;
    
    self.videoHeight = MEKPlayerViewHeightSizeMinimized;
    self.videoWidth = self.videoHeight * MEKPlayerViewVideoRatio;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
        [self minimizeUI];
    } completion:nil];
}

#pragma mark - Private

- (BOOL)setUIwithVideoItem: (VideoItemMO*) item
{
    if (!item)
    {
        return NO;
    }
    
    self.item = item;
    
    if (self.item.title && self.item.author)
    {
        self.titleLabel.text = item.title;
        self.authorLabel.text = item.author;
        
        self.playerController.playingInfo = @{MPMediaItemPropertyTitle : item.title,
                                              MPMediaItemPropertyArtist : item.author
                                              };
    }
    else
    {
        [self.loader loadVideoItem:item];
        return NO;
    }
    
    double progress = [self.downloadController getProgressForKey:item.videoId];
    if ([item hasDownloaded])
        progress = 1;
    
    [self.downloadButton setProgress:progress];
    
    [UIImage ch_downloadImageFromUrl:self.item.thumbnailSmall completion:^(UIImage *image) {
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return image;
        }];
        
        NSMutableDictionary *playerInfo = self.playerController.playingInfo.mutableCopy;
        playerInfo[MPMediaItemPropertyArtwork] = albumArt;
        
        self.playerController.playingInfo = playerInfo;
    }];
    
    return YES;
}

- (BOOL)setVideoWithQuality: (VideoItemQuality) quality
{
    if (!self.item)
    {
        return NO;
    }
    
    self.quality = quality;
    
    NSURL *downloadedURL = self.item.downloadedURLs[@(quality)];
    NSURL *webURL = self.item.urls[@(quality)];
    
    if (!downloadedURL && !webURL)
    {
        [self.loader loadVideoItem:self.item];
        return NO;
    }
    
    NSURL *url = downloadedURL ?: webURL;
    
    self.playerController.player = [AVPlayer playerWithURL:url];
    self.playerController.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    [self.playerController.player play];
    
    return YES;
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

#pragma mark - Selectors

- (void)backgroundTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerViewControllerOpen)])
    {
        [self.delegate videoPlayerViewControllerOpen];
    }
}

- (void)qualityButtonPressed:(UIButton *)button
{
    [self showQualityDialogForCurrentQuality:self.quality handler:^(VideoItemQuality quality) {
        if (self.quality == quality)
        {
            return;
        }

        [self setVideoWithQuality:quality];
    }];
}

- (void)addButtonPressed:(UIButton *)button
{
    [self videoItemAddToPlaylist:self.item];
}

- (void)downloadButtonPressed:(UIButton *)button
{
    if (!self.downloadButton.isLoading)
    {
        [self videoItemDownload:self.item];
    }
    else
    {
        [self videoItemCancelDownload:self.item];
    }
}

- (void)closeButtonPressed: (UIButton*) button
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerViewControllerClosed)])
    {
        [self.delegate videoPlayerViewControllerClosed];
    }
}

#pragma mark - MEKWebVideoLoaderOutputProtocol

- (void)webVideoLoader:(id<MEKWebVideoLoaderInputProtocol>)loader didLoadItem:(VideoItemMO *)item
{
    [self setUIwithVideoItem:self.item];
    [self setVideoWithQuality:self.quality];
}

#pragma mark - MEKVideoItemDelegate

- (void)videoItemAddToPlaylist:(VideoItemMO *)item
{
    [self choosePlaylistForVideoItem:item];
}

- (void)videoItemAddToPlaylist:(VideoItemMO *)item playlist:(PlaylistMO *)playlist
{
    [playlist addVideoItem:item];
}

- (void)videoItemDownload: (VideoItemMO*) item
{
    [self showDownloadingDialogForVideoItem:item handler:^(VideoItemQuality quality) {
        [self videoItemDownload:item withQuality:quality];
    }];
}

- (void)videoItemDownload:(VideoItemMO *)item withQuality:(VideoItemQuality)quality
{
    [self.downloadController downloadDataFromURL:item.urls[@(quality)] forKey:item.videoId withParams:@{@"quality" : @(quality)}];
}

- (void)videoItemCancelDownload:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadForKey:item.videoId];
}

#pragma mark - MEKDownloadControllerDelegate

- (void)downloadControllerProgress:(double)progress forKey:(NSString *)key withParams:(NSDictionary *)params
{
    if (![key isEqualToString:self.item.videoId])
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downloadButton setProgress:progress];
    });
}

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    if (![key isEqualToString:self.item.videoId])
        return;
    
    NSNumber *quality = params[@"quality"];
    [self.item saveTempPathURL:url withQuality:quality.unsignedIntegerValue];
}

- (void)downloadControllerDidFinishWithError:(NSError *)error forKey:(NSString *)key withParams:(NSDictionary *)params
{
    if (![key isEqualToString:self.item.videoId])
        return;
    
    if (error)
    {
        [self downloadControllerProgress:0 forKey:key withParams:params];
    }
}

#pragma mark - MEKModalPlaylistsViewControllerDelegate

- (void)modalPlaylistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist forVideoItem:(VideoItemMO *)item
{
    [self videoItemAddToPlaylist:item playlist:playlist];
}

@end
