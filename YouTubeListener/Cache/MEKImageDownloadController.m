//
//  MEKImageDownloadController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKImageDownloadController.h"
#import "MEKDownloadController.h"
#import "MEKCombinedCache.h"

static NSString * const MEKImageDownloadKey = @"image";

@interface MEKImageDownloadController() <MEKDownloadControllerDelegate>

@property (nonatomic, strong) MEKDownloadController *downloadController;

@end

@implementation MEKImageDownloadController

- (instancetype)init
{
    MEKCombinedCache *cache = [[MEKCombinedCache alloc] init];
    return [self initWithCache:cache];
}

- (instancetype)initWithCache:(MEKCombinedCache *)cache
{
    self = [super init];
    if (self)
    {
        _cache = cache;
        _downloadController = [[MEKDownloadController alloc] initWithBackgroundMode:NO];
        _downloadController.delegate = self;
    }
    return self;
}

- (void)downloadImageFromURL:(NSURL *)url
{
    UIImage *image = [self.cache.primaryCache objectForKey:url.absoluteString];
    if (image)
    {
        [self.delegate imageDownloadController:self didLoadImage:image fromCache:YES];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        NSData *data = [self.cache.secondaryCache objectForKey:url.absoluteString];

        if (!data)
        {
            [self.downloadController downloadDataFromURL:url forKey:MEKImageDownloadKey withParams:@{@"url" : url}];
            return;
        }

        UIImage *image = [UIImage imageWithData:data];
        [self.cache.primaryCache setObject:image forKey:url.absoluteString];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imageDownloadController:self didLoadImage:image fromCache:YES];
        });
    });
}

- (BOOL)hasDownloading
{
    return [self.downloadController hasDownloadForKey:MEKImageDownloadKey];
}

- (void)cancelDownloading
{
    [self.downloadController cancelDownloadForKey:MEKImageDownloadKey];
}

- (BOOL)downloadControllerDidFinish:(id<MEKDownloadControllerInputProtocol>)downloadController withTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];

    url = params[@"url"];
    [self.cache.primaryCache setObject:image forKey:url.absoluteString];
    [self.cache.secondaryCache setObject:data forKey:url.absoluteString];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate imageDownloadController:self didLoadImage:image fromCache:NO];
    });

    return YES;
}

@end
