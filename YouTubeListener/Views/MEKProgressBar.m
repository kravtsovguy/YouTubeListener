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
        self.backgroundColor = UIColor.clearColor;
        
        _progressBarWidth = 0;
        
        _progressLayer = [[CAShapeLayer alloc] init];
        [_progressLayer setStrokeColor:[UIColor.redColor colorWithAlphaComponent:0.7].CGColor];
        [_progressLayer setFillColor:UIColor.clearColor.CGColor];
        [_progressLayer setLineWidth:_progressBarWidth];
        [_progressLayer setStrokeEnd:0];
        _progressLayer.lineCap = kCALineCapRound;
        
        _backProgressLayer = [[CAShapeLayer alloc] init];
        [_backProgressLayer setStrokeColor:[[UIColor grayColor] colorWithAlphaComponent:0.3f].CGColor];
        [_backProgressLayer setFillColor:UIColor.clearColor.CGColor];
        [_backProgressLayer setLineWidth:_progressBarWidth];
        [_backProgressLayer setStrokeEnd:1];
        
        
        [self.layer addSublayer:_backProgressLayer];
        [self.layer addSublayer:_progressLayer];
    }
    return self;
    
}

#pragma mark - Properties

- (void)setProgressBarWidth:(CGFloat)radius
{
    _progressBarWidth = radius;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_progressBarWidth / 2, _progressBarWidth / 2, self.bounds.size.width - _progressBarWidth , self.bounds.size.height - _progressBarWidth) cornerRadius:(self.bounds.size.width - _progressBarWidth) / 2];
    
    
    [self.progressLayer setPath:bezierPath.CGPath];
    [self.progressLayer setLineWidth:_progressBarWidth];
    
    [self.backProgressLayer setPath:bezierPath.CGPath];
    [self.backProgressLayer setLineWidth:_progressBarWidth];
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
