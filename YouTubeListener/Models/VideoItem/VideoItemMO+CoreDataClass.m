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

#pragma mark - Static Properties

+ (NSString *)entityName
{
    return @"VideoItem";
}

#pragma mark - Creation

+ (VideoItemMO*)getEmptyWithContext:(NSManagedObjectContext *)context
{
    VideoItemMO *item =  [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    
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
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:NO selector:@selector(caseInsensitiveCompare:)];
    fetchRequest.sortDescriptors = @[dateDescriptor];
    
    NSArray *result = [self executeFetchRequest:fetchRequest withContext:context];
    return result;
}

#pragma mark - Basic

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

- (BOOL)removeDownloadAll
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
