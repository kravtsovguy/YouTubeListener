//
//  MEKInfoView.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 19/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKInfoView.h"
#import <Masonry/Masonry.h>

@interface MEKInfoView()

@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation MEKInfoView

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 100, 50)];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _infoLabel = [UILabel new];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.numberOfLines = 0;
        _infoLabel.text = @"Info";
        _infoLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        _infoLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [self addSubview:_infoLabel];
    }
    
    return self;
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)updateConstraints
{
    [self.infoLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];

    [super updateConstraints];
}

@end
