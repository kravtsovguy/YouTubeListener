//
//  MEKDowloadButton.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDowloadButton.h"
#import "MEKProgressBar.h"

@interface MEKDowloadButton ()

@property (nonatomic, strong) MEKProgressBar *progressBar;
@property (nonatomic, strong) UIView *stopView;
@property (nonatomic, strong) UIImage *downloadImage;
@property (nonatomic, strong) UIImage *doneImage;

@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, assign, getter=isDone) BOOL done;

@end

@implementation MEKDowloadButton

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
        _progressBar = [MEKProgressBar new];
        _progressBar.userInteractionEnabled = NO;
        _progressBar.hidden = YES;
        [self addSubview:_progressBar];
        
        
        _stopView = [UIView new];
        _stopView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _stopView.layer.masksToBounds = YES;
        _stopView.userInteractionEnabled = NO;
        _stopView.hidden = YES;
        [self addSubview:_stopView];
        
        _downloadImage = [UIImage imageNamed:@"download"];
        _doneImage = [UIImage imageNamed:@"downloaded"];
        [self setImage:_downloadImage forState:UIControlStateNormal];
    }
    
    return self;
}

#pragma mark - Properties

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    
    if (_loading)
    {
        [self setImage:nil forState:UIControlStateNormal];
        self.progressBar.hidden = NO;
        self.stopView.hidden = NO;
    }
    else
    {
        [self setImage:self.downloadImage forState:UIControlStateNormal];
        self.progressBar.progress = 0;
        self.progressBar.hidden = YES;
        self.stopView.hidden = YES;
    }
    
    self.userInteractionEnabled = YES;
}

- (void)setDone:(BOOL)done
{
    _done = done;
    
    self.loading = NO;
    
    if (_done)
    {
        [self setImage:self.doneImage forState:UIControlStateNormal];
    }
    
    self.userInteractionEnabled = !_done;
}

- (void)setProgress:(double)progress
{
    self.progressBar.progress = progress;
    
    if (progress < 1)
    {
        self.loading = progress > 0;
    }
    else
    {
        self.done = YES;
    }
}

- (CGFloat)progress
{
    return self.progressBar.progress;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.progressBar.frame = self.bounds;
    
    CGFloat stopViewSize = CGRectGetHeight(self.frame) / 3;
    self.stopView.frame = CGRectMake((CGRectGetWidth(self.frame) - stopViewSize)/ 2, (CGRectGetHeight(self.frame) - stopViewSize)/ 2, stopViewSize, stopViewSize);
    self.stopView.layer.cornerRadius = stopViewSize / 4;
}
@end
