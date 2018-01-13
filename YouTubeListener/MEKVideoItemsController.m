//
//  MEKVideoItemsController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemsController.h"
#import "AppDelegate.h"

@interface MEKVideoItemsController ()

@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;

@end

@implementation MEKVideoItemsController

- (NSManagedObjectContext*) coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    NSPersistentContainer *container = ((AppDelegate*)(application.delegate)).persistentContainer;
    
    NSManagedObjectContext *context = container.viewContext;
    
    return context;
}

- (PlaylistMO *)addPlaylistWithName:(NSString *)name
{
    if ([self getPlaylistForName:name])
        return nil;
    
    PlaylistMO *playlist = [self getEmptyPlaylist];
    
    playlist.name = name;
    playlist.items = [NSArray new];
    
    [self savePlaylist:playlist];
    
    return playlist;
}

- (void)renamePlaylist:(PlaylistMO *)playlist toName:(NSString *)name
{
    if ([name isEqualToString:@"Recent"])
        return;
    
    playlist.name = name;
    [self savePlaylist:playlist];
}

-(BOOL)containsVideoItem:(VideoItemMO *)item forPlaylist:(PlaylistMO *)playlist
{
    BOOL contains = [playlist.items indexOfObject:item.videoId] != NSNotFound;
    return contains;
}

-(void)addVideoItem:(VideoItemMO *)item toPlaylist:(PlaylistMO *)playlist
{
    if ([self containsVideoItem:item forPlaylist:playlist])
    {
        [self deleteVideoItem:item fromPlaylist:playlist];
    }
    
    NSMutableArray *items = playlist.items.mutableCopy;
    [items insertObject:item.videoId atIndex:0];
    playlist.items = items;
    [self savePlaylist:playlist];
}

- (void)deleteVideoItem:(VideoItemMO *)item fromPlaylist:(PlaylistMO *)playlist
{
    if (![self containsVideoItem:item forPlaylist:playlist])
        return;
    
    NSMutableArray *items = playlist.items.mutableCopy;
    NSUInteger index = [playlist.items indexOfObject:item.videoId];
    [items removeObjectAtIndex:index];
    playlist.items = items;
    
    [self savePlaylist:playlist];
}

-(PlaylistMO *)getRecentPlaylist
{
    PlaylistMO *recent = [self getPlaylistForName:@"Recent"];
    if (!recent)
        recent = [self addPlaylistWithName:@"Recent"];
    
    return recent;
}

-(void)addVideoItemToRecentPlaylist:(VideoItemMO *)item
{
    PlaylistMO *recent = [self getRecentPlaylist];
    [self addVideoItem:item toPlaylist:recent];
}

-(VideoItemMO *)getFirstVideoItemForPlaylist:(PlaylistMO *)playlist
{
    if (!playlist)
        return nil;
    
    NSString *videoId = playlist.items.firstObject;
    VideoItemMO *item = [self getVideoItemForId:videoId];
    return item;
}

-(NSArray<PlaylistMO *> *)getPlaylists
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]  initWithEntityName:@"Playlist"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name <> [c] %@", @"Recent"];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *itemsCountDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"items.count" ascending:NO];
    fetchRequest.sortDescriptors = @[nameDescriptor,itemsCountDescriptor];
    
    NSError *error = nil;
    NSArray *result = [self.coreDataContext executeFetchRequest:fetchRequest error:&error];
    
    if (!result)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    return result;
}

-(PlaylistMO *)getPlaylistForName:(NSString *)name
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]  initWithEntityName:@"Playlist"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == [c] %@", name];
    
    NSError *error = nil;
    NSArray *result = [self.coreDataContext executeFetchRequest:fetchRequest error:&error];
    
    if (!result)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    PlaylistMO *playlist = result.count > 0 ? result[0] : nil;
    
    return playlist;
}

- (PlaylistMO *)getEmptyPlaylist
{
    PlaylistMO *playlist = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:self.coreDataContext];
    
    return playlist;
}

- (void)savePlaylist:(PlaylistMO *)playlist
{
    NSError *error = nil;
    if(![playlist.managedObjectContext save:&error])
    {
        NSLog(@"Can't save the object");
    }
}

- (void)deletePlaylist: (PlaylistMO*) playlist
{
    [self.coreDataContext deleteObject:playlist];
    
    NSError *error = nil;
    if(![self.coreDataContext save:&error])
    {
        NSLog(@"Can't delete the object");
    }
}

- (VideoItemMO *)getEmptyVideoItem
{
    VideoItemMO *item = [NSEntityDescription insertNewObjectForEntityForName:@"VideoItem" inManagedObjectContext:self.coreDataContext];
    
    return item;
}

-(NSArray<VideoItemMO *> *)getVideoItems
{
    NSError *error = nil;
    NSArray *result = [self.coreDataContext executeFetchRequest:VideoItemMO.fetchRequest error:&error];
    
    if (!result)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    return result;
}

-(NSArray<VideoItemMO *> *)getVideoItemsForPlaylist:(PlaylistMO *)playlist
{
    if (!playlist)
        return nil;
    
    NSMutableArray *items = [NSMutableArray new];
    
    for (NSString *videoId in playlist.items)
    {
        [items addObject:[self getVideoItemForId:videoId]];
    }
    
    return items;
}

-(VideoItemMO *)getVideoItemForId:(NSString *)videoId
{
    if (!videoId)
        return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]  initWithEntityName:@"VideoItem"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"videoId == %@", videoId];
    
    NSError *error = nil;
    NSArray *result = [self.coreDataContext executeFetchRequest:fetchRequest error:&error];
    
    if (!result)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    VideoItemMO *item = result.count > 0 ? result[0] : nil;
    
    return item;
}

- (void)saveVideoItem:(VideoItemMO *)item
{
    NSError *error = nil;
    if(![item.managedObjectContext save:&error])
    {
        NSLog(@"Can't save the object");
    }
}

- (void)deleteVideoItem:(VideoItemMO *)item
{
    [self.coreDataContext deleteObject:item];
    
    NSError *error = nil;
    if(![self.coreDataContext save:&error])
    {
        NSLog(@"Can't delete the object");
    }
}

@end
