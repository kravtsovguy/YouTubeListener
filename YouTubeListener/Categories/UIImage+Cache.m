//
//  UIImage+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImage+Cache.h"
#import "MEKCombinedCache.h"
#import "MEKDownloadController.h"

@implementation UIImage(Cache)

+ (MEKCombinedCache *)ch_cache
{
    static MEKCombinedCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[MEKCombinedCache alloc] init];
    });

    return cache;
}

#pragma mark - Public Static

+ (void)ch_downloadImageFromUrl:(NSURL *)url completion:(void (^)(UIImage *, BOOL))completion
{
    if (!url)
    {
        return;
    }

    MEKCombinedCache *cache = [self ch_cache];

    UIImage *image = [cache.primaryCache objectForKey:url.absoluteString];
    if (image)
    {
        completion(image, YES);
        return;
    }


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        NSData *data = [cache.secondaryCache objectForKey:url.absoluteString];
        BOOL isCached = data;

        if (!data)
        {
            data = [NSData dataWithContentsOfURL:url];
            [cache.secondaryCache setObject:data forKey:url.absoluteString];
        }

        UIImage *image = [UIImage imageWithData:data];
        [cache.primaryCache setObject:image forKey:url.absoluteString];

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image, isCached);
        });
    });
}

@end
