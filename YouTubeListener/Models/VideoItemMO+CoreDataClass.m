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

+ (NSArray<VideoItemMO*>*)executeFetchRequest: (NSFetchRequest*) request withContext: (NSManagedObjectContext*) context;

@end

@implementation VideoItemMO

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

+ (NSString *)entityName
{
    return @"VideoItem";
}

// Creation
+ (VideoItemMO*)getEmptyWithContext:(NSManagedObjectContext *)context
{
    VideoItemMO *item =  [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    
    return item;
}

// Instance Accessors
+ (VideoItemMO*)getVideoItemForId: (NSString*) videoId withContext:(nonnull NSManagedObjectContext *)context
{
    if (!videoId)
        return nil;
    
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

// Basic
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

- (NSURL *)getPathUrlWithQuality:(VideoItemQuality)quality
{
    NSString * path = [self getPathDirectory];
    path = [path stringByAppendingPathComponent:@(quality).stringValue];
    path = [path stringByAppendingPathExtension:@"mp4"];
    return [NSURL fileURLWithPath:path];
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

- (NSArray<NSString *> *)getQualityOfDownloads
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self getPathDirectory];
    
    NSError *error;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
    
    NSMutableArray *qualities = [NSMutableArray new];
    
    for (NSString *file in files)
    {
        NSString *quality = [file componentsSeparatedByString:@"."].firstObject;
        [qualities addObject:@(quality.integerValue)];
    }
    
    return qualities;
}

- (BOOL)hasDownloadedWithQuality:(VideoItemQuality)quality
{
    NSArray *qualities = [self getQualityOfDownloads];
    BOOL isDownloaded = [qualities indexOfObject:@(quality).stringValue] != NSNotFound;
    
    return isDownloaded;
}

- (BOOL)hasDownloaded
{
    NSArray *qualities = [self getQualityOfDownloads];
    return qualities.count > 0;
}


@end
