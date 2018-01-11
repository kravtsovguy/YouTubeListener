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

@end

@implementation MEKDowloadButton

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 50, 50)];
}

-(instancetype)initWithFrame:(CGRect)frame
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
        [self setImage:_image forState:UIControlStateNormal];

        //self.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.tintColor = [UIColor blueColor];
    }
    
    return self;
}

-(void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    
    if (_isLoading)
    {
        [self setImage:nil forState:UIControlStateNormal];
        self.progressBar.hidden = NO;
        self.stopView.hidden = NO;
    }
    else
    {
        [self setImage:self.image forState:UIControlStateNormal];
        self.progressBar.hidden = YES;
        self.stopView.hidden = YES;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
