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

- (NSURL *)getPathUrl
{
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:self.videoId];
    path = [path stringByAppendingPathExtension:@"mp4"];
    return [NSURL fileURLWithPath:path];
}

- (BOOL)saveTempPathURL:(NSURL *)url
{
    if (!url)
    {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL isMoved = [fileManager moveItemAtURL:url toURL:[self getPathUrl] error:&error];
    
    return isMoved;
}

- (BOOL)removeDownload
{
    if ([self hasDownloaded])
    {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL isRemoved = [fileManager removeItemAtURL:[self getPathUrl] error:&error];
    
    return isRemoved;
}

- (BOOL)hasDownloaded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isExists = [fileManager fileExistsAtPath:[self getPathUrl].path];
    
    return isExists;
}


@end
