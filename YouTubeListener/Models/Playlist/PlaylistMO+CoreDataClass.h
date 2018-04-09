//
//  PlaylistMO+CoreDataClass.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VideoItemMO;

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistMO : NSManagedObject

+ (NSString*)entityName;
+ (NSString*)recentPlaylistName;
+ (NSString*)downloadsPlaylistName;

// Creation
+ (PlaylistMO*)emptyWithContext: (NSManagedObjectContext*) context;
+ (PlaylistMO*)playlistWithName: (NSString*) name withContext: (NSManagedObjectContext*) context;

// Editing
- (BOOL)rename: (NSString*) name;
- (BOOL)addVideoItem: (VideoItemMO*) item;
- (BOOL)deleteVideoItem: (VideoItemMO*) item;

// Accessors
- (NSArray<VideoItemMO*>*)videoItems;
- (VideoItemMO*)firstVideoItem;
- (BOOL)containsVideoItem: (VideoItemMO*) item;

// Instance Accessors
+ (NSArray<PlaylistMO*>*)executeFetchRequest: (NSFetchRequest*) request withContext: (NSManagedObjectContext*) context;
+ (NSArray<PlaylistMO*>*)playlistsWithContext: (NSManagedObjectContext*) context;
+ (PlaylistMO*)playlistForName: (NSString*) name withContext: (NSManagedObjectContext*) context;

// Basic
- (BOOL)saveObject;
- (BOOL)deleteObject;

@end

NS_ASSUME_NONNULL_END

#import "PlaylistMO+CoreDataProperties.h"
