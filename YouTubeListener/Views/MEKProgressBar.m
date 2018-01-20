//
//  MEKProgressBar.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKProgressBar.h"

@interface MEKProgressBar ()

@property (nonatomic, assign) CGFloat radius;

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
        
        _radius = 0;
        _progress = 0;
        
        _progressLayer = [[CAShapeLayer alloc] init];
        [_progressLayer setStrokeColor:[UIColor.redColor colorWithAlphaComponent:0.7].CGColor];
        [_progressLayer setFillColor:UIColor.clearColor.CGColor];
        [_progressLayer setLineWidth:_radius];
        [_progressLayer setStrokeEnd:_progress];
        _progressLayer.lineCap = kCALineCapRound;
        
        _backProgressLayer = [[CAShapeLayer alloc] init];
        [_backProgressLayer setStrokeColor:[[UIColor grayColor] colorWithAlphaComponent:0.3f].CGColor];
        [_backProgressLayer setFillColor:UIColor.clearColor.CGColor];
        [_backProgressLayer setLineWidth:_radius];
        [_backProgressLayer setStrokeEnd:1];
        
        
        [self.layer addSublayer:_backProgressLayer];
        [self.layer addSublayer:_progressLayer];
    }
    return self;
    
}

#pragma mark - Properties

- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_radius / 2, _radius / 2, self.bounds.size.width - _radius , self.bounds.size.height - _radius) cornerRadius:(self.bounds.size.width - _radius) / 2];
    
    
    [self.progressLayer setPath:bezierPath.CGPath];
    [self.progressLayer setLineWidth:_radius];
    
    [self.backProgressLayer setPath:bezierPath.CGPath];
    [self.backProgressLayer setLineWidth:_radius];
}

- (void)setProgress:(CGFloat)progress
{
    if (progress < 0 || progress > 1)
    {
        return;
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
    self.radius = CGRectGetHeight(self.frame) * 0.1;
}

@end
