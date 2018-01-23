//
//  MEKProgressBar.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKProgressBar.h"

@interface MEKProgressBar ()

@property (nonatomic, assign) CGFloat progressBarWidth;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *backProgressLayer;

@end

@implementation MEKProgressBar

#pragma mark - init

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 50, 50)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _progressBarWidth = 0;
        
        _progressLayer = [CAShapeLayer new];
        _progressLayer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7].CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.lineWidth = _progressBarWidth;
        _progressLayer.strokeEnd = 0;
        _progressLayer.lineCap = kCALineCapRound;
        
        _backProgressLayer = [CAShapeLayer new];
        _backProgressLayer.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:0.3f].CGColor;
        _backProgressLayer.fillColor = [UIColor clearColor].CGColor;
        _backProgressLayer.lineWidth = _progressBarWidth;
        _backProgressLayer.strokeEnd = 1;
        
        [self.layer addSublayer:_backProgressLayer];
        [self.layer addSublayer:_progressLayer];
    }
    return self;
    
}

#pragma mark - Properties

- (void)setProgressBarWidth:(CGFloat)radius
{
    _progressBarWidth = radius;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_progressBarWidth / 2, _progressBarWidth / 2, CGRectGetWidth(self.bounds) - _progressBarWidth , CGRectGetHeight(self.bounds) - _progressBarWidth) cornerRadius:(CGRectGetWidth(self.bounds) - _progressBarWidth) / 2];
    
    
    self.progressLayer.path = bezierPath.CGPath;
    self.progressLayer.lineWidth = _progressBarWidth;
    
    self.backProgressLayer.path = bezierPath.CGPath;
    self.backProgressLayer.lineWidth = _progressBarWidth;
}

- (void)setProgress:(CGFloat)progress
{
    if (progress < 0)
    {
        progress = 0;
    }
    
    if (progress > 1)
    {
        progress = 1;
    }

    self.progressLayer.strokeEnd = progress;
}

- (CGFloat)progress
{
    return self.progressLayer.strokeEnd;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.progressBarWidth = CGRectGetHeight(self.frame) * 0.1;
}

@end
