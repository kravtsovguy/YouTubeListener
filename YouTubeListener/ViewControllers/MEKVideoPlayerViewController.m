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
#import "UIImage+Cache.h"
#import "AppDelegate.h"
#import "VideoItemMO+CoreDataClass.h"
#import "MEKVideoItemDownloadController.h"
#import "MEKCombinedActionController.h"
#import "MEKVideoItemActionController+Alerts.h"

#import <Masonry/Masonry.h>

@import MediaPlayer;


CGFloat const MEKPlayerViewHeightSizeMaximized = 320;
CGFloat const MEKPlayerViewHeightSizeMinimized = 60;
CGFloat const MEKPlayerViewVideoRatio = 16.0f / 9.0f;
VideoItemQuality const MEKPlayerViewDefaultQuality = VideoItemQualityMedium360;

@interface MEKVideoPlayerViewController () <MEKVideoItemActionProtocol, MEKVideoItemDownloadControllerDelegate, MEKWebVideoLoaderOutputProtocol>

@property (nonatomic, strong) MEKCombinedActionController *actionController;
@property (nonatomic, strong) MEKPlayerViewController *playerController;
@property (nonatomic, strong) MEKWebVideoLoader *loader;


@property (nonatomic, copy) NSDictionary *itemJSON;
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
@property (nonatomic, strong) UIButton *qualityButton;
@property (nonatomic, strong) MEKDowloadButton *downloadButton;
@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation MEKVideoPlayerViewController

#pragma mark - init

- (instancetype)initWithVideoItem:(VideoItemMO *)item
{
    self = [super init];
    if (self)
    {
        _actionController = [[MEKCombinedActionController alloc] init];
        _actionController.videoItemActionController.delegate = self;

        _itemJSON = [item toDictionary];
        _item = item;
        _quality = MEKPlayerViewDefaultQuality;
        
        if ([_item hasDownloaded])
        {
            _quality = [_item downloadedQuality];
        }
        
        [self maximizeWithDuration:0];
    }
    return self;
}

#pragma mark - Properties

- (MEKVideoItemDownloadController *)downloadController
{
    return self.actionController.downloadController;
}

- (NSManagedObjectContext *)coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *delegate = (AppDelegate*)application.delegate;

    return delegate.persistentContainer.viewContext;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *lightBlack = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    [self.view addSubview:self.titleLabel];
    
    self.authorLabel = [UILabel new];
    self.authorLabel.numberOfLines = 1;
    self.authorLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [self.view addSubview:self.authorLabel];
    
    self.closeButton = [UIButton new];
    [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    self.closeButton.tintColor = lightBlack;
    self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    [self.closeButton addTarget:self action:@selector(p_closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.closeButton];
    
    self.addButton = [UIButton new];
    [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    self.addButton.tintColor = lightBlack;
    [self.addButton addTarget:self action:@selector(p_addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];

    self.downloadButton = [MEKDowloadButton new];
    self.downloadButton.tintColor = lightBlack;
    [self.downloadButton addTarget:self action:@selector(p_downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
    
    self.qualityButton = [UIButton new];
    [self.qualityButton setImage:[UIImage imageNamed:@"gear"] forState:UIControlStateNormal];
    self.qualityButton.tintColor = lightBlack;
    [self.qualityButton addTarget:self action:@selector(p_qualityButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.qualityButton];
    
    self.moreButton = [UIButton new];
    [self.moreButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    self.moreButton.tintColor = lightBlack;
    [self.moreButton addTarget:self action:@selector(p_moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.moreButton];
    
    [self p_setButtonsHidden:YES];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.alpha = 0;
    self.blurEffectView.frame = self.view.bounds;
    self.blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.blurEffectView atIndex:0];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_backgroundTapped:)];
    [self.view addGestureRecognizer:singleTapRecognizer];
    
    self.playerController = [MEKPlayerViewController new];
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.borderWidth = 0.5;
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = YES;
    
    self.loader = [MEKWebVideoLoader new];
    self.loader.output = self;

    BOOL isSetUI = [self p_setUIwithVideoItem:self.item];
    BOOL isSetVideo = [self p_setVideoWithQuality:self.quality];

    if (!isSetUI || !isSetVideo)
    {
        [self.loader loadVideoItem:self.item];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.downloadController.delegate = self;
    [self p_setUIwithVideoItem:self.item];
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
            make.right.equalTo(self.closeButton.mas_left);
        }
    }];
    
    [self.authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.maximized)
        {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(15);
            make.left.equalTo(self.view.mas_left).with.offset(10);
            make.right.equalTo(self.addButton.mas_left).with.offset(-10);
        }
        else
        {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(10);
            make.left.equalTo(self.playerController.view.mas_right).with.offset(10);
            make.right.equalTo(self.closeButton.mas_left);
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
    
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qualityButton.mas_top);
        make.right.equalTo(self.qualityButton.mas_left).with.offset(-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];

    [self.downloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qualityButton.mas_top);
        make.right.equalTo(self.qualityButton.mas_left).with.offset(-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];

    [self.qualityButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moreButton.mas_top);
        make.right.equalTo(self.moreButton.mas_left).with.offset(-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.moreButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.maximized)
        {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(10);
        }
        else
        {
            make.top.equalTo(self.playerController.view.mas_bottom).with.offset(10);
        }

        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
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
        [self p_maximizeUI];
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
        [self p_minimizeUI];
    } completion:nil];
}

#pragma mark - Private

- (void)p_setButtonsHidden: (BOOL) hidden
{
    self.downloadButton.hidden = hidden;
    self.addButton.hidden = hidden;
    self.qualityButton.hidden = hidden;
    self.moreButton.hidden = hidden;
}

- (BOOL)p_setUIwithVideoItem: (VideoItemMO*) item
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
        
        [self p_setButtonsHidden:NO];
    }
    else
    {
        return NO;
    }

    BOOL isAddedToLibrary = [item addedToLibrary:self.coreDataContext];
    self.addButton.hidden = isAddedToLibrary;
    self.downloadButton.hidden = !isAddedToLibrary;

    double progress = [self.downloadController progressForVideoItem:item];
    if ([item hasDownloaded])
    {
        progress = 1;
    }
    
    [self.downloadButton setProgress:progress];
    
    [UIImage ch_downloadImageFromUrl:self.item.thumbnailSmall completion:^(UIImage *image, BOOL fromCache) {
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return image;
        }];
        
        NSMutableDictionary *playerInfo = self.playerController.playingInfo.mutableCopy;
        playerInfo[MPMediaItemPropertyArtwork] = albumArt;
        
        self.playerController.playingInfo = playerInfo;
    }];
    
    return YES;
}

- (BOOL)p_setVideoWithQuality: (VideoItemQuality) quality
{
    if (!self.item)
    {
        return NO;
    }
    
    self.quality = quality;
    
    NSURL *downloadedURL = self.item.downloadedURLs[@(quality)];
    NSURL *webURL = self.item.urls[@(quality)];

    if (!webURL)
    {
        webURL = self.item.urls[VideoItemHTTPLiveStreaming];
    }
    
    if (!downloadedURL && !webURL)
    {
        return NO;
    }
    
    NSURL *url = downloadedURL ?: webURL;
    
    self.playerController.player = [AVPlayer playerWithURL:url];
    self.playerController.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    [self.playerController.player play];
    
    return YES;
}

- (void)p_maximizeUI
{
    self.view.layer.cornerRadius = 10;
    self.view.backgroundColor = [UIColor whiteColor];
    self.blurEffectView.alpha = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
    self.titleLabel.numberOfLines = 2;
    
    self.authorLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
}

- (void)p_minimizeUI
{
    self.view.layer.cornerRadius = 0;
    self.view.backgroundColor = [UIColor clearColor];
    self.blurEffectView.alpha = 1;
    self.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    self.titleLabel.numberOfLines = 1;
    
    self.authorLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightLight];
}

- (void)p_backgroundTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerViewControllerOpen)])
    {
        [self.delegate videoPlayerViewControllerOpen];
    }
}

- (void)p_moreButtonPressed:(UIButton *)button
{
    [self.actionController.videoItemActionController showActionDialog:self.item];
}

- (void)p_qualityButtonPressed:(UIButton *)button
{
    [self.actionController.videoItemActionController showPlayQualityDialog:self.item withCurrentQuality:self.quality];
}

- (void)p_addButtonPressed:(UIButton *)button
{
    [self.actionController.videoItemActionController videoItemAddToLibrary:self.item];
}

- (void)p_downloadButtonPressed:(MEKDowloadButton *)downloadButton
{
    if (!downloadButton.isLoading)
    {
        [self.actionController.videoItemActionController showDownloadQualityDialog:self.item];
    }
    else
    {
        [self.actionController.videoItemActionController videoItemCancelDownload:self.item];
    }
}

- (void)p_closeButtonPressed: (UIButton*) button
{
    if ([self.delegate respondsToSelector:@selector(videoPlayerViewControllerClosed)])
    {
        [self.delegate videoPlayerViewControllerClosed];
    }
}

#pragma mark - MEKVideoItemActionProtocol

- (void)videoItemAddToLibrary:(VideoItemMO *)item
{
    [self p_setUIwithVideoItem:item];
}

- (void)videoItemRemoveFromLibrary:(VideoItemMO *)item
{
    item = [VideoItemMO disconnectedEntityWithContext:self.coreDataContext];
    [item setupWithDictionary:self.itemJSON];
    self.item = item;

    [self p_setUIwithVideoItem:item];
}

- (void)videoItemRemoveDownload:(VideoItemMO *)item
{
    [self p_setUIwithVideoItem:item];
}

- (void)videoItem:(VideoItemMO *)item playWithQuality:(VideoItemQuality)quality
{
    if (self.quality == quality)
    {
        return;
    }

    if ([self p_setVideoWithQuality:quality])
    {
        return;
    }

    [self.loader loadVideoItem:self.item];
}

#pragma mark - MEKWebVideoLoaderOutputProtocol

- (void)webVideoLoader:(id<MEKWebVideoLoaderInputProtocol>)loader didLoadItem:(VideoItemMO *)item
{
    [self p_setUIwithVideoItem:self.item];
    [self p_setVideoWithQuality:self.quality];
}

#pragma mark - MEKVideoItemDownloadControllerDelegate

- (void)videoItemDownloadControllerProgress:(double)progress forVideoItem:(VideoItemMO *)item
{
    if (![item.videoId isEqualToString:self.item.videoId])
    {
        return;
    }
    
    [self.downloadButton setProgress:progress];
}

- (void)videoItemDownloadControllerDidFinishWithError:(NSError *)error forVideoItem:(VideoItemMO *)item
{
    if (![item.videoId isEqualToString:self.item.videoId])
    {
        return;
    }

    [self videoItemDownloadControllerProgress:error ? 0 : 1 forVideoItem:item];
}

@end
