//
//  MEKLoaderTableViewCell.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 22/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKLoaderTableViewCell.h"
#import <Masonry/Masonry.h>

@interface MEKLoaderTableViewCell ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation MEKLoaderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = NO;
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimating];
        [self.contentView addSubview:_activityIndicator];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect viewBounds = self.contentView.bounds;
    self.activityIndicator.center = CGPointMake(CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds));
}

+ (CGFloat)height
{
    return 50;
}

@end
