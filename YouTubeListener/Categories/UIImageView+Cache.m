//
//  UIImageView+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImageView+Cache.h"
#import "UIImage+Cache.h"

@implementation UIImageView(Cache)


- (void)ch_downloadImageFromUrl:(NSURL *)url
{
    if (!url)
    {
        return;
    }
    
    [UIImage ch_downloadImageFromUrl:url completion:^(UIImage *image) {
        
        [UIView transitionWithView:self
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.image = image;
                        } completion:nil];
        
    }];
}

@end
