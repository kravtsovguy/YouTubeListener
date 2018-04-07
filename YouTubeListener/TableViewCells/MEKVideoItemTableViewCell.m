//
//  MEKVideoItemTableViewCell.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemTableViewCell.h"
#import <Masonry/Masonry.h>
#import "UIImageView+Cache.h"
#import "MEKDowloadButton.h"
#import "VideoItemMO+CoreDataClass.h"
#import "MEKVideoItemActionController+Alerts.h"

@interface MEKVideoItemTableViewCell ()

@property (nonatomic, strong) VideoItemMO *item;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIView *durationView;
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) MEKDowloadButton *downloadButton;
@property (nonatomic, strong) UILabel *downloadInfoLabel;

@end

@implementation MEKVideoItemTableViewCell

#pragma mark - init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIColor *lightBlack = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        _titleLabel.text = @"Video Title";
        [self.contentView addSubview:_titleLabel];
        
        _authorLabel = [UILabel new];
        _authorLabel.numberOfLines = 1;
        _authorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _authorLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        _authorLabel.text = @"Author";
        [self.contentView addSubview:_authorLabel];
        
        _thumbnailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder"]];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
        _thumbnailImageView.layer.masksToBounds = YES;
        _thumbnailImageView.layer.cornerRadius = 5;
        [self.contentView addSubview:_thumbnailImageView];
        
        _durationView = [UIView new];
        _durationView.layer.cornerRadius = 2;
        _durationView.layer.masksToBounds = YES;
        _durationView.backgroundColor = lightBlack;
        [_thumbnailImageView addSubview:_durationView];
        
        _durationLabel = [UILabel new];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _durationLabel.text = @"12:06";
        [_durationView addSubview:_durationLabel];
        
        _addButton = [UIButton new];
        [_addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        _addButton.tintColor = lightBlack;
        [_addButton addTarget:self action:@selector(p_addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_addButton];
        
        _downloadButton = [[MEKDowloadButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _downloadButton.tintColor = lightBlack;
        [_downloadButton addTarget:self action:@selector(p_downloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_downloadButton];
        
        _downloadInfoLabel = [UILabel new];
        _downloadInfoLabel.numberOfLines = 1;
        _downloadInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _downloadInfoLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightUltraLight];
        _downloadInfoLabel.text = @"";
        [self.contentView addSubview:_downloadInfoLabel];
    }
    
    return self;
}

#pragma mark - UIView

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)updateConstraints
{
    [self.thumbnailImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(10);
        make.left.equalTo(self.contentView.mas_left).with.offset(10);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
        make.width.equalTo( self.thumbnailImageView.mas_height ).multipliedBy( 16.0 / 9.0 );
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(10);
        make.left.equalTo(self.thumbnailImageView.mas_right).with.offset(10);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
    }];
    
    [self.authorLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(5);
        make.left.equalTo(self.thumbnailImageView.mas_right).with.offset(10);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
    }];
    
    [self.durationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.thumbnailImageView.mas_right).with.offset(-5);
        make.bottom.equalTo(self.thumbnailImageView.mas_bottom).with.offset(-5);
    }];
    
    [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.durationView.mas_top).with.offset(5);
        make.left.equalTo(self.durationView.mas_left).with.offset(5);
        make.right.equalTo(self.durationView.mas_right).with.offset(-5);
        make.bottom.equalTo(self.durationView.mas_bottom).with.offset(-5);
    }];
    
    [self.addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.authorLabel.mas_bottom).with.offset(5);
        make.left.equalTo(self.authorLabel.mas_left);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.downloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addButton.mas_top);
        make.left.equalTo(self.addButton.mas_left);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    [self.downloadInfoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.downloadButton.mas_top);
        make.left.equalTo(self.downloadButton.mas_right).with.offset(10);
        make.height.equalTo(@30);
    }];

    [super updateConstraints];
}

#pragma mark - Public

- (void)setWithVideoItem:(VideoItemMO *)item addedToLibrary:(BOOL)isAddedToLibrary
{
    if (!item)
    {
        return;
    }
    
    self.item = item;
    
    self.titleLabel.text = item.title;
    self.authorLabel.text = item.author;
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:item.length];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    df.dateFormat = @"mm:ss";
    
    NSInteger length = item.length;
    NSInteger hours = length / 60 / 60;
    if (hours > 0)
        df.dateFormat = @"HH:mm:ss";
    
    self.durationLabel.text = [df stringFromDate:date];

    UIImage *placeholder = [UIImage imageNamed:@"placeholder"];
    [self.thumbnailImageView ch_downloadImageFromUrl:item.thumbnailBig usingPlaceholder:placeholder];

    self.addButton.hidden = isAddedToLibrary;
    self.downloadButton.hidden = !self.addButton.hidden;
    self.downloadInfoLabel.hidden = self.downloadButton.hidden;
    
    if ([item hasDownloaded])
    {
        VideoItemQuality quality = item.downloadedQuality;
        NSString *qualityString = [VideoItemMO getQualityString:quality];
        NSNumber *size = item.downloadedSizes.allValues.firstObject;

        self.downloadInfoLabel.text = [NSString stringWithFormat:@"(%@ | %@MB)", qualityString, size];
    }
    else
    {
        self.downloadInfoLabel.text = @"";
    }
}

- (void)setDownloadProgress:(double)progress
{
    [self.downloadButton setProgress:progress];
}

+ (CGFloat)height
{
    return 120;
}

#pragma mark - Selectors

- (void)p_addButtonPressed:(UIButton *)button
{
    [self.videoItemActionController videoItemAddToLibrary:self.item];
}

- (void)p_downloadButtonPressed:(UIButton *)button
{
    if (!self.downloadButton.isLoading)
    {
        [self.videoItemActionController showDownloadQualityDialog:self.item];
    }
    else
    {
        [self.videoItemActionController videoItemCancelDownload:self.item];
    }
}

@end
