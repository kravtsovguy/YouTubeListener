//
//  MEKDowloadButton.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDowloadButton.h"

@interface MEKDowloadButton ()

@property (nonatomic, strong) UIView *stopView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *doneImage;

@end

@implementation MEKDowloadButton

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 50, 50)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.progressBar = [[MEKProgressBar alloc] initWithFrame:self.bounds];
        self.progressBar.userInteractionEnabled = NO;
        self.progressBar.hidden = YES;
        [self addSubview:self.progressBar];
        
        CGFloat stopViewSize = CGRectGetHeight(frame) / 3;

        _stopView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - stopViewSize)/ 2, (self.frame.size.height - stopViewSize)/ 2, stopViewSize, stopViewSize)];
        _stopView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.7];
        _stopView.layer.cornerRadius = stopViewSize / 4;
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

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    destImage = [destImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return destImage;
}

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
}

- (void)setDone:(BOOL)done
{
    _done = done;
    
    self.userInteractionEnabled = !_done;
    self.loading = NO;
    
    if (_done)
    {
        [self setImage:self.doneImage forState:UIControlStateNormal];
    }
}

@end
