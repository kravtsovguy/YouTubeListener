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

- (void)addPlaylistWithName: (NSString*) name
{
    
    PlaylistMO *playlist = [self getEmptyPlaylist];
    
    playlist.name = name;
    playlist.items = [NSOrderedSet new];
    
    [self savePlaylist:playlist];
}

-(void)addVideoItem:(VideoItemMO *)item toPlaylist:(PlaylistMO *)playlist
{
    NSMutableOrderedSet *items = playlist.items.mutableCopy;
    [items addObject:item];
    playlist.items = items;
    
    [self savePlaylist:playlist];
}

-(NSArray<PlaylistMO *> *)getPlaylists
{
    NSError *error = nil;
    NSArray *result = [self.coreDataContext executeFetchRequest:PlaylistMO.fetchRequest error:&error];
    
    if (!result)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    return result;
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
