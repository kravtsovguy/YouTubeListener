//
//  UIImage+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImage+Cache.h"
#import <objc/runtime.h>

static void *CachePropertyKey = &CachePropertyKey;

@implementation UIImage(Cache)

#pragma mark - Properties

+ (void)ch_setCache: (NSDictionary*)cache
{
    objc_setAssociatedObject(self, CachePropertyKey, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSDictionary *)ch_cache
{
    return objc_getAssociatedObject(self, CachePropertyKey) ?: @{};
}

#pragma mark - Public Static

+ (void)ch_downloadImageFromUrl:(NSURL *)url completion:(void (^)(UIImage *))completion
{
    if (!url)
    {
        return;
    }

    NSMutableDictionary *cache = [self ch_cache].mutableCopy;
    UIImage *cachedImage = cache[url];
    if (cachedImage)
    {
        completion(cachedImage);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        
        NSData *data = [self ch_getDataForUrl:url];
        if (!data)
        {
            data = [NSData dataWithContentsOfURL:url];
            [self ch_saveData:data ForUrl:url];
        }
        
        UIImage *image = [UIImage imageWithData:data];

        cache[url] = image;
        [self ch_setCache:cache];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(image);
            
        });
    });
}

#pragma mark - Private Static

+ (void)ch_saveData:(NSData*)data ForUrl: (NSURL*)url
{
    NSString *path = [self ch_getPathForUrl:url];
    
    NSError *error;
    if (![data writeToFile:path options:NSDataWritingAtomic error:&error])
    {
        NSLog(@"Error Writing File : %@",error.localizedDescription);
    }
}

+ (NSData*)ch_getDataForUrl: (NSURL*)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self ch_getPathForUrl:url];
    if([fileManager fileExistsAtPath:path])
    {
        return [NSData dataWithContentsOfFile:path];
    }
    else
    {
        return nil;
    }
}

+ (NSString*)ch_getPathForUrl: (NSURL*)url
{
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *urlName = [self ch_getNameFromUrl:url];
    path = [path stringByAppendingPathComponent:@"images"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:path isDirectory:nil])
    {
        NSError *error;
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    path = [path stringByAppendingPathComponent:urlName];
    return path;
}

+ (NSString*)ch_getNameFromUrl: (NSURL*)url
{
    NSString *path = url.path;
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    return path;
}

@end
