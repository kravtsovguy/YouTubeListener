//
//  VideoItemMO+CoreDataClass.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "VideoItemMO+CoreDataClass.h"


NSString *const VideoItemHTTPLiveStreaming = @"HTTPLiveStreaming";

@interface VideoItemMO()

- (NSURL*)pathUrlWithQuality: (VideoItemQuality) quality;

@end

@implementation VideoItemMO

+ (NSArray<NSNumber *> *)allQualities
{
    NSArray *qualities = @[@(VideoItemQualityHD720),
                           @(VideoItemQualityMedium360),
                           @(VideoItemQualitySmall240),
                           @(VideoItemQualitySmall144)];
    
    return qualities;
}

+ (NSString *)qualityString:(VideoItemQuality)quality
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

+ (VideoItemMO*)connectedEntityWithContext:(NSManagedObjectContext *)context
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

+ (VideoItemMO*)videoItemForURL:(NSURL *)videoURL withContext:(NSManagedObjectContext *)context
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

+ (VideoItemMO*)videoItemForId: (NSString*) videoId withContext:(nonnull NSManagedObjectContext *)context
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

+ (NSArray<VideoItemMO*>*)videoItemsWithContext:(NSManagedObjectContext *)context
{
    NSArray *result = [self executeFetchRequest:[self fetchRequest] withContext:context];
    return result;
}

+ (NSArray<VideoItemMO *> *)addedVideoItemsWithContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:NO];
    fetchRequest.sortDescriptors = @[dateDescriptor];
    
    NSArray *result = [self executeFetchRequest:fetchRequest withContext:context];
    return result;
}

+ (NSArray<VideoItemMO *> *)videoItemsFromJSON:(NSArray<NSDictionary *> *)videosJSON withContext:(NSManagedObjectContext *)context
{
    NSMutableArray<VideoItemMO *> *videos = @[].mutableCopy;

    [videosJSON enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        VideoItemMO *video = [VideoItemMO disconnectedEntityWithContext:context];
        [video setupWithDictionary:obj];
        [videos addObject:video];
    }];

    return videos;
}

#pragma mark - History

+ (NSArray<VideoItemMO *> *)historyVideoItemsFromUserDefaults:(NSUserDefaults *)userDefaults withContext:(NSManagedObjectContext *)context
{
    NSArray<NSDictionary *> *videosJSON = [userDefaults objectForKey:@"history"];
    return [self videoItemsFromJSON:videosJSON withContext:context];
}

+ (void)removeHistoryForUserDefaults:(NSUserDefaults *)userDefaults
{
    [userDefaults removeObjectForKey:@"history"];
}

- (void)addToHistoryForUserDefaults:(NSUserDefaults *)userDefaults
{
    id object = [userDefaults objectForKey:@"history"] ?: @[];
    NSMutableArray<NSDictionary *> *videosJSON = [object mutableCopy];

    [videosJSON filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF[\"id\"] != %@", self.videoId]];
    [videosJSON insertObject:[self toDictionary] atIndex:0];

    NSUInteger limit = 50;
    NSRange removingRange = videosJSON.count > limit ? NSMakeRange(limit, videosJSON.count - limit) : NSMakeRange(0, 0);
    [videosJSON removeObjectsInRange:removingRange];

    [userDefaults setObject:videosJSON forKey:@"history"];
    [userDefaults synchronize];
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
    self.urls = json[@"urls"];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = @{}.mutableCopy;

    dictionary[@"id"] = self.videoId;
    dictionary[@"title"] = self.title;
    dictionary[@"author"] = self.author;
    dictionary[@"length_seconds"] = @(self.length).stringValue;
    dictionary[@"thumbnail_small"] = self.thumbnailSmall.absoluteString;
    dictionary[@"thumbnail_large"] = self.thumbnailBig.absoluteString;
    dictionary[@"source"] = self.originURL.absoluteString;

    return dictionary;
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

#pragma mark - Library

- (BOOL)addedToLibrary:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[self class] fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"videoId == %@", self.videoId];

    NSError *error;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];

    return (count != NSNotFound) ? count : 0;
}

- (void)addToLibrary:(NSManagedObjectContext *)context
{
    if ([self addedToLibrary:context])
    {
        return;
    }

    self.added = [NSDate new];
    [context insertObject:self];
    [self saveObject];
}

- (void)removeFromLibrary:(NSManagedObjectContext *)context
{
    VideoItemMO *item = [[self class] videoItemForId:self.videoId withContext:context];
    [item deleteObject];
}

#pragma mark - Downloading Public

- (NSString *)pathDirectory
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
    BOOL isMoved = [fileManager moveItemAtURL:url toURL:[self pathUrlWithQuality:quality] error:&error];
    
    return isMoved;
}

- (BOOL)removeAllDownloads
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    BOOL isRemoved = [fileManager removeItemAtPath:[self pathDirectory] error:&error];
    
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
    BOOL isRemoved = [fileManager removeItemAtURL:[self pathUrlWithQuality:quality] error:&error];
    
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
    NSString *path = [self pathDirectory];
    
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

- (NSURL *)pathUrlWithQuality:(VideoItemQuality)quality
{
    NSString * path = [self pathDirectory];
    path = [path stringByAppendingPathComponent:@(quality).stringValue];
    path = [path stringByAppendingPathExtension:@"mp4"];
    return [NSURL fileURLWithPath:path];
}


@end
