//
//  UIImage+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImage+Cache.h"

@implementation UIImage(Cache)

#pragma mark - Public Static

+ (void)ch_downloadImageFromUrl:(NSURL *)url completion:(void (^)(UIImage *))completion
{
    if (!url)
    {
        return;
    }

    static NSDictionary *cache;

    UIImage *image = cache[url];
    if (image)
    {
        completion(image);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        UIImage *image = [self ch_imageForUrl:url];
        cache = [self ch_addImage:image forURL:url toCache:cache];

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    });
}

#pragma mark - Private Static

+ (NSDictionary*)ch_addImage: (UIImage*)image forURL: (NSURL*)url toCache: (NSDictionary*)cache
{
    if (!url || !image)
    {
        return cache;
    }

    cache = cache ?: @{};
    NSMutableDictionary *mutableCache = [cache mutableCopy];
    mutableCache[url] = image;
    return mutableCache;
}

+ (UIImage*)ch_imageForUrl: (NSURL*)url
{
    NSData *data = [self ch_dataForUrl:url];
    if (!data)
    {
        data = [NSData dataWithContentsOfURL:url];
        [self ch_saveData:data ForUrl:url];
    }

    UIImage *image = [UIImage imageWithData:data];
    return image;
}

+ (BOOL)ch_saveData:(NSData*)data ForUrl: (NSURL*)url
{
    NSString *path = [self ch_pathForUrl:url];
    BOOL isSaved = [data writeToFile:path options:NSDataWritingAtomic error:nil];
    return isSaved;
}

+ (NSData*)ch_dataForUrl: (NSURL*)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self ch_pathForUrl:url];
    if([fileManager fileExistsAtPath:path])
    {
        return [NSData dataWithContentsOfFile:path];
    }
    else
    {
        return nil;
    }
}

+ (NSString*)ch_pathForUrl: (NSURL*)url
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *urlName = [self ch_nameFromUrl:url];
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

+ (NSString*)ch_nameFromUrl: (NSURL*)url
{
    NSString *path = url.path;
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    return path;
}

@end
