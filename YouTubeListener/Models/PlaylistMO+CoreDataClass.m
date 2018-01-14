//
//  PlaylistMO+CoreDataClass.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "PlaylistMO+CoreDataClass.h"

@implementation PlaylistMO

+ (NSString *)entityName
{
    return @"Playlist";
}

+ (NSString *)recentPlaylistName
{
    return @"Recent";
}

// Creation
+ (PlaylistMO*)getEmptyWithContext: (NSManagedObjectContext*) context
{
    PlaylistMO *item =  [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    
    return item;
}

+ (PlaylistMO*)playlistWithName: (NSString*) name withContext: (NSManagedObjectContext*) context
{
    if ([self getPlaylistForName:name withContext:context])
        return nil;
    
    PlaylistMO *playlist = [self getEmptyWithContext:context];
    
    playlist.name = name;
    playlist.items = [NSArray new];
    
    [playlist saveObject];
    
    return playlist;
}

// Editing
- (BOOL)rename: (NSString*) name
{
    if ([name isEqualToString:[PlaylistMO recentPlaylistName]])
        return NO;
    
    self.name = name;
    return [self saveObject];
}

- (BOOL)addVideoItem: (VideoItemMO*) item
{
    if ([self containsVideoItem:item])
    {
        [self deleteVideoItem:item];
    }
    
    NSMutableArray *items = self.items.mutableCopy;
    [items insertObject:item.videoId atIndex:0];
    
    self.items = items;
    
    return [self saveObject];
}

- (BOOL)deleteVideoItem: (VideoItemMO*) item
{
    if (![self containsVideoItem:item])
    {
        return NO;
    }
    
    NSMutableArray *items = self.items.mutableCopy;
    NSUInteger index = [self.items indexOfObject:item.videoId];
    [items removeObjectAtIndex:index];
    
    self.items = items;
    
    return [self saveObject];
}

// Accessors
- (NSArray<VideoItemMO*>*)getVideoItems
{
    NSMutableArray *items = [NSMutableArray new];
    
    for (NSString *videoId in self.items)
    {
        [items addObject:[VideoItemMO getVideoItemForId:videoId withContext:self.managedObjectContext]];
    }
    
    return items;
}

- (VideoItemMO*)getFirstVideoItem
{
    NSString *videoId = self.items.firstObject;
    VideoItemMO *item = [VideoItemMO getVideoItemForId:videoId withContext:self.managedObjectContext];
    return item;
}

- (BOOL)containsVideoItem: (VideoItemMO*) item
{
    BOOL contains = [self.items indexOfObject:item.videoId] != NSNotFound;
    return contains;
}

// Instance Accessors
+ (NSArray<PlaylistMO*>*)getPlaylistsWithContext: (NSManagedObjectContext*) context
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name <> [c] %@", [PlaylistMO recentPlaylistName]];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    fetchRequest.sortDescriptors = @[nameDescriptor];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!result)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    return result;
}

+ (PlaylistMO*)getRecentPlaylistWithContext: (NSManagedObjectContext*) context
{
    PlaylistMO *recent = [self getPlaylistForName:[PlaylistMO recentPlaylistName] withContext:context];
    if (!recent)
        recent = [self playlistWithName:[PlaylistMO recentPlaylistName] withContext:context];
    
    return recent;
}

+ (PlaylistMO*)getPlaylistForName: (NSString*) name withContext: (NSManagedObjectContext*) context
{
    NSFetchRequest *fetchRequest = [self fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == [c] %@", name];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!result)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    PlaylistMO *playlist = result.count > 0 ? result[0] : nil;
    
    return playlist;
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

@end
