//
//  MEKDowloadButton.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDowloadButton.h"

const static CGFloat StopViewSize = 20;

@interface MEKDowloadButton ()

@property (nonatomic, strong) UIView *stopView;
@property (nonatomic, strong) UIImage *image;

@end

@implementation MEKDowloadButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.progressBar = [[MEKProgressBar alloc] initWithFrame:self.bounds];
        self.progressBar.userInteractionEnabled = NO;
        [self addSubview:self.progressBar];

        _stopView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - StopViewSize)/ 2, (self.frame.size.height - StopViewSize)/ 2, StopViewSize, StopViewSize)];
        _stopView.backgroundColor = UIColor.blueColor;
        _stopView.layer.cornerRadius = StopViewSize / 4;
        _stopView.layer.masksToBounds = YES;
        _stopView.userInteractionEnabled = NO;
        _stopView.hidden = YES;
        [self addSubview:_stopView];
        
        _image = [UIImage imageNamed:@"download"];
        [self setImage:_image forState:UIControlStateNormal];

        self.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
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
        self.stopView.hidden = NO;
    }
    else
    {
        [self setImage:self.image forState:UIControlStateNormal];
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
