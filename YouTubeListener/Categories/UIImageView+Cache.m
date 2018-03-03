//
//  UIImageView+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImageView+Cache.h"
#import "MEKImageDownloadController.h"
#import "MEKCombinedCache.h"
#import <objc/runtime.h>

@interface UIImageView(Cache_ImageDownloadController) <MEKImageDownloadControllerDelegate>

@property (nonatomic, strong, readonly) MEKImageDownloadController *ch_downloadController;

@end

@implementation UIImageView(Cache_ImageDownloadController)
@dynamic ch_downloadController;

+ (MEKCombinedCache *)ch_cache
{
    static MEKCombinedCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[MEKCombinedCache alloc] init];
    });

    return cache;
}

- (MEKImageDownloadController *)ch_downloadController
{
    MEKImageDownloadController *downloadController = objc_getAssociatedObject(self, @selector(ch_downloadController));
    if (!downloadController)
    {
        MEKCombinedCache *cache = [[self class] ch_cache];
        downloadController = [[MEKImageDownloadController alloc] initWithCache:cache];
        downloadController.delegate = self;

        objc_setAssociatedObject(self, @selector(ch_downloadController), downloadController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return downloadController;
}

- (void)imageDownloadController:(MEKImageDownloadController *)controller didLoadImage:(UIImage *)image fromCache:(BOOL)cached
{
    NSTimeInterval duration = cached ? 0.0 : 0.2;

    [UIView transitionWithView:self
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.image = image;
                    } completion:nil];
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

    MEKImageDownloadController *downloadController = self.ch_downloadController;
    [downloadController cancelDownloading];
    [downloadController downloadImageFromURL:url];
}

@end
