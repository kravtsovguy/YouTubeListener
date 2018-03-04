//
//  UIImageView+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImageView+Cache.h"
#import "MEKDownloadController.h"
#import "MEKAsyncCombinedCache.h"
#import <objc/runtime.h>

@interface UIImageView(Cache_Properties)

@property (nonatomic, strong, readonly) MEKAsyncCombinedCache *ch_cache;
@property (nonatomic, strong, readonly) MEKDownloadController *ch_downloadController;

@end

@interface UIImageView(Cache_Delegates) <MEKDownloadControllerDelegate, MEKAsyncCombinedCacheDelegate>

@end

@implementation UIImageView(Cache_Properties)

+ (MEKAsyncCombinedCache *)ch_cache
{
    static MEKAsyncCombinedCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[MEKAsyncCombinedCache alloc] init];
    });

    return cache;
}

- (MEKAsyncCombinedCache *)ch_cache
{
    MEKAsyncCombinedCache *cache = objc_getAssociatedObject(self, @selector(ch_cache));
    if (!cache)
    {
        cache = [[[self class] ch_cache] copy];
        cache.delegate = self;

        objc_setAssociatedObject(self, @selector(ch_cache), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return cache;
}

- (MEKDownloadController *)ch_downloadController
{
    MEKDownloadController *downloadController = objc_getAssociatedObject(self, @selector(ch_downloadController));
    if (!downloadController)
    {
        downloadController = [[MEKDownloadController alloc] initWithBackgroundMode:NO];
        downloadController.delegate = self;

        objc_setAssociatedObject(self, @selector(ch_downloadController), downloadController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return downloadController;
}

@end

@implementation UIImageView(Cache_Delegates)

- (BOOL)downloadControllerDidFinish:(id<MEKDownloadControllerInputProtocol>)downloadController withTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSURL *originURL = params[@"url"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self.ch_cache setObject:data forKey:originURL.absoluteString withCost:data.length];

    return YES;
}

- (id)asyncCombinedCache:(MEKAsyncCombinedCache *)combinedCache primaryObjectFromSecondaryObject:(id)secondaryObject
{
    NSData *data = secondaryObject;
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

- (void)asyncCombinedCache:(MEKAsyncCombinedCache *)combinedCache objectNotFoundForKey:(NSString *)key
{
    NSURL *url = [NSURL URLWithString:key];
    [self.ch_downloadController downloadDataFromURL:url forKey:@"image" withParams:@{@"url" : url}];
}

- (void)asyncCombinedCache:(MEKAsyncCombinedCache *)combinedCache primaryObjectFound:(id)object forKey:(NSString *)key fromCache:(id<MEKCacheInputProtocol>)cache
{
    NSTimeInterval duration = cache ? 0.0 : 0.2;
    UIImage *image = object;

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.image = image;
                        } completion:nil];
    });
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

    [self.ch_downloadController cancelAllDownloads];
    [self.ch_cache objectForKey:url.absoluteString];
}

@end
