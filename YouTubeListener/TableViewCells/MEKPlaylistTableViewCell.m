//
//  PlaylistTableViewCell.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistTableViewCell.h"
#import <Masonry/Masonry.h>
#import "UIImageView+Cache.h"

@interface MEKPlaylistTableViewCell()

@property (nonatomic, strong) PlaylistMO *playlist;

@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation MEKPlaylistTableViewCell

#pragma mark - init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder"]];
        _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _titleImageView.clipsToBounds = YES;
        _titleImageView.layer.cornerRadius = 5;
        _titleImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_titleImageView];
        
        _nameLabel = [UILabel new];
        _nameLabel.text = @"Playlist's name";
        _nameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        [self.contentView addSubview:_nameLabel];
        
        _countLabel = [UILabel new];
        _countLabel.text = @"10 Videos";
        _countLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        [self.contentView addSubview:_countLabel];
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
    [self.titleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(10);
        make.left.equalTo(self.contentView.mas_left).with.offset(10);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
        make.width.equalTo( self.titleImageView.mas_height ).multipliedBy( 1.0 / 1.0 );
    }];

    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(20);
        make.left.equalTo(self.titleImageView.mas_right).with.offset(10);
    }];

    [self.countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(5);
        make.left.equalTo(self.titleImageView.mas_right).with.offset(10);
    }];

    [super updateConstraints];
}

#pragma mark - Public

- (void)setWithName:(NSString *)playlistName itemsCount:(NSUInteger)count imageURL:(NSURL *)url
{
    self.nameLabel.text = playlistName;
    self.countLabel.text = [NSString stringWithFormat:@"%li videos", count];
    self.titleImageView.image = [UIImage imageNamed:@"placeholder"];

    if (url)
    {
        [self.titleImageView ch_downloadImageFromUrl:url];
    }
}

+ (CGFloat)height
{
    return 80;
}

@end
