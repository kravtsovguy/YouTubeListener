//
//  MEKImageLoader.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 05/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKImageLoader.h"
#import "MEKAsyncCombinedCache.h"
#import "MEKDownloadController.h"
#import <UIKit/UIKit.h>

@interface MEKImageLoader () <MEKDownloadControllerDelegate, MEKAsyncCombinedCacheDelegate>

@property (nonatomic, copy) MEKAsyncCombinedCache *cache;
@property (nonatomic, strong) MEKDownloadController *downloadController;
@property (nonatomic, copy) NSMapTable *table;

@end

@implementation MEKImageLoader

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (instancetype)init
{
    MEKAsyncCombinedCache *cache = [MEKAsyncCombinedCache sharedInstance];
    return [self initWithCache:cache];
}

- (instancetype)initWithCache:(MEKAsyncCombinedCache *)cache
{
    self = [super init];
    if (self)
    {
        _cache = [cache copy];
        _cache.delegate = self;

        _downloadController = [[MEKDownloadController alloc] initWithBackgroundMode:NO];
        _downloadController.delegate = self;

        _table = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableCopyIn];
    }
    return self;
}

- (void)loadImageFromUrl:(NSURL *)url completion:(ImageLoaderCompletionBlock)completion
{
    [self cancelLoadForUrl:url];
    [self.table setObject:completion forKey:url.absoluteString];
    [self.cache objectForKey:url.absoluteString];
}

- (void)loadImageFromUrl:(NSURL *)url
{
    [self cancelLoadForUrl:url];
    [self.cache objectForKey:url.absoluteString];
}

- (void)cancelLoadForUrl:(NSURL *)url
{
    [self.table removeObjectForKey:url.absoluteString];
    [self.downloadController cancelDownloadForKey:url.absoluteString];
}

- (void)cancelAllLoads
{
    [self.table removeAllObjects];
    [self.downloadController cancelAllDownloads];
}

- (BOOL)downloadControllerDidFinish:(id<MEKDownloadControllerInputProtocol>)downloadController withTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSURL *originURL = params[@"url"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    [self.cache setObject:data forKey:originURL.absoluteString withCost:data.length];

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
    [self.downloadController downloadDataFromURL:url forKey:url.absoluteString withParams:@{@"url" : url}];
}

- (void)asyncCombinedCache:(MEKAsyncCombinedCache *)combinedCache primaryObjectFound:(id)primaryObject forKey:(NSString *)key fromCache:(id<MEKCacheInputProtocol>)cache
{
    void (^completion)(void) = ^{
        UIImage *image = primaryObject;
        BOOL cached = cache;

        ImageLoaderCompletionBlock block = [self.table objectForKey:key];
        if (block)
        {
            [self.table removeObjectForKey:key];
            block(image, cached);
            return;
        }

        NSURL *url = [NSURL URLWithString:key];
        [self.delegate imageDownloader:self didLoadImage:image forUrl:url fromCache:cached];
    };

    if (cache == combinedCache.primaryCache)
    {
        completion();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), completion);
    }
}

@end
