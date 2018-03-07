//
//  UIImageView+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImageView+Cache.h"
#import "MEKImageLoader.h"
#import <objc/runtime.h>

@interface UIImageView(Cache_Properties)

@property (nonatomic, strong, readonly) MEKImageLoader *ch_imageLoader;

@end

@implementation UIImageView(Cache_Properties)

- (MEKImageLoader *)ch_imageLoader
{
    MEKImageLoader *imageLoader = objc_getAssociatedObject(self, @selector(ch_imageLoader));
    if (!imageLoader)
    {
        imageLoader = [[MEKImageLoader alloc] init];
        objc_setAssociatedObject(self, @selector(ch_imageLoader), imageLoader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return imageLoader;
}

@end

@implementation UIImageView(Cache)

#pragma mark - Public

- (void)ch_downloadImageFromUrl:(NSURL *)url
{
    [self ch_downloadImageFromUrl:url usingPlaceholder:nil];
}

- (void)ch_downloadImageFromUrl:(NSURL *)url usingPlaceholder:(UIImage *)placeholder
{
    if (!url)
    {
        return;
    }

    if (placeholder)
    {
        self.image = placeholder;
    }

    [self.ch_imageLoader cancelAllLoads];
    [self.ch_imageLoader loadImageFromUrl:url completion:^(UIImage *image, BOOL cached) {
        [UIView transitionWithView:self
                          duration:cached ? 0.0 : 0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.image = image;
                        } completion:nil];
    }];
}

@end
