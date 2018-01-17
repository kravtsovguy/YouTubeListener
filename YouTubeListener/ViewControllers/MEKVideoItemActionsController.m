//
//  MEKVideoItemActionsController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 18/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemActionsController.h"
#import "MEKDowloadButton.h"
#import "MEKModalPlaylistsViewController.h"
#import "MEKYouTubeVideoParser.h"
#import <Masonry/Masonry.h>

@interface MEKVideoItemActionsController () <MEKModalPlaylistsViewControllerDelegate, MEKWebVideoParserOutputProtocol, MEKVideoItemDelegate, MEKDownloadControllerDelegate>

@property (nonatomic, strong) VideoItemMO *item;

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) MEKDowloadButton *downloadButton;
@property (nonatomic, strong) MEKWebVideoParser *parser;

@end

@implementation MEKVideoItemActionsController

#pragma mark - init

- (instancetype)initWithVideoItem:(VideoItemMO *)item
{
    self = [self init];
    if (self)
    {
        _item = item;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _parser = [MEKYouTubeVideoParser new];
        _parser.output = self;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addButton = [UIButton new];
    [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    self.addButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    
    self.downloadButton = [[MEKDowloadButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.downloadButton.tintColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
    [self.downloadButton addTarget:self action:@selector(downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
}

#pragma mark - UIView

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)updateViewConstraints
{
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.downloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_right).with.offset(10);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Private

- (UIAlertAction*)createActionForQuality: (VideoItemQuality) quality
{
    NSString *qualityString = [VideoItemMO getQualityString:quality];
    NSString *name = qualityString;
    
    NSNumber *size = self.item.sizes[@(quality)];
    if (![size isEqualToNumber:@(0)])
    {
        name = [NSString stringWithFormat:@"%@ (%@MB)", qualityString, size];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self videoItemDownload:self.item withQuality:quality];
    }];
    
    return action;
}

- (void)showDownloadingDialog
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Quality"
                                                                   message:@"Available formats"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancedlAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:[self createActionForQuality:VideoItemQualityHD720]];
    [alert addAction:[self createActionForQuality:VideoItemQualityMedium360]];
    [alert addAction:[self createActionForQuality:VideoItemQualitySmall240]];
    [alert addAction:[self createActionForQuality:VideoItemQualitySmall144]];
    [alert addAction:cancedlAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setDownloadProgress:(double)progress
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

#pragma mark - Selectors

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

#pragma mark - MEKVideoItemDelegate

- (void)videoItemAddToPlaylist:(VideoItemMO *)item
{
    MEKModalPlaylistsViewController *playlistsController = [MEKModalPlaylistsViewController new];
    playlistsController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)videoItemAddToPlaylist:(VideoItemMO *)item playlist:(PlaylistMO *)playlist
{
    [playlist addVideoItem:self.item];
}

- (void)videoItemDownload: (VideoItemMO*) item;
{
    if (item.urls)
    {
        [self showDownloadingDialog];
    }
    else
    {
        [self.parser loadVideoItem:item];
    }
}

- (void)videoItemDownload:(VideoItemMO *)item withQuality:(VideoItemQuality)quality
{
    [self.downloadController downloadDataFromURL:self.item.urls[@(quality)] forKey:self.item.videoId withParams:@{@"quality" : @(quality)}];
}

- (void)videoItemCancelDownload:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadForKey:self.item.videoId];
}

#pragma mark - MEKModalPlaylistsViewControllerDelegate

- (void)modalPlaylistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist
{
    [self videoItemAddToPlaylist:self.item playlist:playlist];
}

#pragma mark - MEKWebVideoParserOutputProtocol

- (void)webVideoParser:(id<MEKWebVideoParserInputProtocol>)parser didLoadItem:(VideoItemMO *)item
{
    [self videoItemDownload:item];
}

#pragma mark - MEKDownloadControllerDelegate

- (void)downloadControllerProgress:(double)progress forKey:(NSString *)key withParams:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self setDownloadProgress:progress];
//
//        if (progress == 1)
//        {
//            [cell setWithVideoItem:item];
//        }
                
    });
}

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    
    NSNumber *quality = params[@"quality"];
    [self.item saveTempPathURL:url withQuality:quality.unsignedIntegerValue];
    
    [self downloadControllerProgress:1 forKey:key withParams:params];
}

- (void)downloadControllerDidFinishWithError:(NSError *)error forKey:(NSString *)key withParams:(NSDictionary *)params
{
    if (error)
    {
        [self downloadControllerProgress:0 forKey:key withParams:params];
    }
}

@end



