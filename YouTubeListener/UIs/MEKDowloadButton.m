//
//  MEKDowloadButton.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDowloadButton.h"

@interface MEKDowloadButton ()

@property (nonatomic, strong) MEKProgressBar *progressBar;
@property (nonatomic, strong) UIView *stopView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *doneImage;

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
        _stopView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _stopView.layer.masksToBounds = YES;
        _stopView.userInteractionEnabled = NO;
        _stopView.hidden = YES;
        [self addSubview:_stopView];
        
        _image = [UIImage imageNamed:@"download"];
        _doneImage = [UIImage imageNamed:@"downloaded"];
        //_image = [self imageWithImage:_image convertToSize:CGSizeMake(100, 100)];
        [self setImage:_image forState:UIControlStateNormal];
        //self.imageView.adjustsImageSizeForAccessibilityContentSizeCategory = YES;
        
        //self.imageView.backgroundColor = UIColor.redColor;
        //self.imageView.contentMode = UIViewContentModeScaleToFill;
        //self.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        //self.tintColor = [UIColor blueColor];
    }
    
    return self;
}

#pragma mark - Public

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
        [self setImage:self.image forState:UIControlStateNormal];
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

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.progressBar.frame = self.bounds;
    
    CGFloat stopViewSize = CGRectGetHeight(self.frame) / 3;
    self.stopView.frame = CGRectMake((self.frame.size.width - stopViewSize)/ 2, (self.frame.size.height - stopViewSize)/ 2, stopViewSize, stopViewSize);
    self.stopView.layer.cornerRadius = stopViewSize / 4;
}

#pragma mark - Trash

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    destImage = [destImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return destImage;
}

@end
