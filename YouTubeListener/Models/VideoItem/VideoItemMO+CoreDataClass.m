//
//  VideoItemMO+CoreDataClass.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "VideoItemMO+CoreDataClass.h"

@interface VideoItemMO()

- (NSURL*)getPathUrlWithQuality: (VideoItemQuality) quality;

@end

@implementation VideoItemMO

+ (NSArray<NSNumber *> *)getAllQualities
{
    NSArray *qualities = @[@(VideoItemQualityHD720),
                           @(VideoItemQualityMedium360),
                           @(VideoItemQualitySmall240),
                           @(VideoItemQualitySmall144)];
    
    return qualities;
}

+ (NSString *)getQualityString:(VideoItemQuality)quality
{
    NSString *qualityString = @"";
    
    switch (quality)
    {
        case VideoItemQualitySmall144:
            qualityString = @"144p";
            break;
            
        case VideoItemQualitySmall240:
            qualityString = @"240p";
            break;
            
        case VideoItemQualityMedium360:
            qualityString = @"360p";
            break;
            
        case VideoItemQualityHD720:
            qualityString = @"720p";
    }
    
    return qualityString;
}

#pragma mark - Static Properties

+ (NSString *)entityName
{
    return @"VideoItem";
}

#pragma mark - Creation

+ (VideoItemMO*)getEmptyWithContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    VideoItemMO *item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];

    return item;
}

+ (VideoItemMO *)disconnectedEntityWithContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    VideoItemMO *item = [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];

    return item;
}

#pragma mark - Instance Accessors

+ (NSArray<VideoItemMO *>*)executeFetchRequest:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (!result)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    return result;
}

+ (VideoItemMO*)getVideoItemForURL:(NSURL *)videoURL withContext:(NSManagedObjectContext *)context
{
    if (!videoURL)
    {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"originURL.absoluteString == %@", videoURL.absoluteString];
    
    NSArray *result = [self executeFetchRequest:fetchRequest withContext:context];
    VideoItemMO *item = result.firstObject;
    
    return item;
}

+ (VideoItemMO*)getVideoItemForId: (NSString*) videoId withContext:(nonnull NSManagedObjectContext *)context
{
    if (!videoId)
    {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"videoId == %@", videoId];
    
    NSArray *result = [self executeFetchRequest:fetchRequest withContext:context];
    VideoItemMO *item = result.firstObject;
    
    return item;
}

+ (NSArray<VideoItemMO*>*)getVideoItemsWithContext:(NSManagedObjectContext *)context
{
    NSArray *result = [self executeFetchRequest:[self fetchRequest] withContext:context];
    return result;
}

+ (NSArray<VideoItemMO *> *)getRecentVideoItemsWithContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:NO];
    fetchRequest.sortDescriptors = @[dateDescriptor];
    
    NSArray *result = [self executeFetchRequest:fetchRequest withContext:context];
    return result;
}

#pragma mark - Basic

- (void)setupWithDictionary:(NSDictionary *)json
{
    self.videoId = json[@"id"];
    self.title = json[@"title"];
    self.author = json[@"author"];
    self.length = [json[@"length_seconds"] doubleValue];
    self.thumbnailSmall = [NSURL URLWithString:json[@"thumbnail_small"]];
    self.thumbnailBig = [NSURL URLWithString:json[@"thumbnail_large"]];
    self.originURL = [NSURL URLWithString:json[@"source"]];
}

- (BOOL)saveObject
{
    NSError *error = nil;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Can't save the object");
        return NO;
    }
    
    return YES;
}

- (BOOL)deleteObject
{
    [self removeAllDownloads];
    
    [self.managedObjectContext deleteObject:self];
    return [self saveObject];
}

#pragma mark - Downloading Public

- (NSString *)getPathDirectory
{
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:self.videoId];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:nil])
    {
        NSError *error;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return path;
}

- (BOOL)saveTempPathURL:(NSURL *)url withQuality:(VideoItemQuality)quality
{
    if (!url)
    {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL isMoved = [fileManager moveItemAtURL:url toURL:[self getPathUrlWithQuality:quality] error:&error];
    
    return isMoved;
}

- (BOOL)removeAllDownloads
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    BOOL isRemoved = [fileManager removeItemAtPath:[self getPathDirectory] error:&error];
    
    return isRemoved;
}

- (BOOL)removeDownloadWithQuality:(VideoItemQuality)quality
{
    if ([self hasDownloadedWithQuality:quality])
    {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL isRemoved = [fileManager removeItemAtURL:[self getPathUrlWithQuality:quality] error:&error];
    
    return isRemoved;
}

- (VideoItemQuality)downloadedQuality
{
    NSDictionary *urls = [self downloadedURLs];
    NSNumber *key = urls.allKeys.firstObject;
    VideoItemQuality quality = key.unsignedIntegerValue;
    
    return quality;
}

- (NSDictionary *)downloadedSizes
{
    NSDictionary *urls = [self downloadedURLs];
    NSMutableDictionary *sizes = [NSMutableDictionary new];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSNumber *key in urls)
    {
        NSURL *url = urls[key];
        NSInteger size = [[fileManager attributesOfItemAtPath:url.path error:nil] fileSize];
        sizes[key] = @(size / 1000 / 1000);
    }
    
    return sizes;
}

- (NSDictionary *)downloadedURLs
{
    if (!self.videoId)
    {
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self getPathDirectory];
    
    NSError *error;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
    

    NSMutableDictionary *urls;
    if (files.count > 0)
    {
        urls = [NSMutableDictionary new];
    }
    
    for (NSString *file in files)
    {
        NSString *quality = [file componentsSeparatedByString:@"."].firstObject;
        NSString *absolutePath = [path stringByAppendingPathComponent:file];
        urls[@(quality.integerValue)] = [NSURL fileURLWithPath:absolutePath];
    }
    
    return urls;
}

- (BOOL)hasDownloadedWithQuality:(VideoItemQuality)quality
{
    NSDictionary *urls = [self urls];
    NSURL *url = urls[@(quality)];
    
    return url;
}

- (BOOL)hasDownloaded
{
    NSDictionary *urls = [self downloadedURLs];
    return urls;
}

#pragma mark - Downloading Private

- (NSURL *)getPathUrlWithQuality:(VideoItemQuality)quality
{
    NSString * path = [self getPathDirectory];
    path = [path stringByAppendingPathComponent:@(quality).stringValue];
    path = [path stringByAppendingPathExtension:@"mp4"];
    return [NSURL fileURLWithPath:path];
}


@end
