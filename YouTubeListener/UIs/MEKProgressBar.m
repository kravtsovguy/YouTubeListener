//
//  MEKProgressBar.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKProgressBar.h"

@interface MEKProgressBar ()

@property (nonatomic, strong) UIView *stopView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *backProgressLayer;
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, strong) CABasicAnimation *animateStrokeDown;

@end

@implementation MEKProgressBar

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _startAngle = M_PI * 1.5;
        _endAngle = _startAngle + (M_PI * 2);
        _progress = 0.0;
        _radius = CGRectGetHeight(frame) * 0.1;
        //CGFloat frameRadius = self.frame.size.width / 2;
        
        self.backgroundColor = UIColor.clearColor;
        
        //self.layer.cornerRadius = frameRadius;
        //self.layer.masksToBounds = YES;
        
        //[UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(_radius,_radius)];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_radius / 2, _radius / 2, self.bounds.size.width - _radius , self.bounds.size.height - _radius) cornerRadius:(self.bounds.size.width - _radius) / 2];
        //[bezierPath addArcWithCenter:CGPointMake(_radius, _radius) radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:YES];
        
        _progressLayer = [[CAShapeLayer alloc] init];
        [_progressLayer setPath:bezierPath.CGPath];
        [_progressLayer setStrokeColor:[UIColor.redColor colorWithAlphaComponent:0.7].CGColor];
        [_progressLayer setFillColor:UIColor.clearColor.CGColor];
        [_progressLayer setLineWidth:_radius];
        [_progressLayer setStrokeEnd:_progress];
        _progressLayer.lineCap = kCALineCapRound;
        
        _backProgressLayer = [[CAShapeLayer alloc] init];
        [_backProgressLayer setPath:bezierPath.CGPath];
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
    self.progressLayer.strokeEnd = progress;
}

@end
