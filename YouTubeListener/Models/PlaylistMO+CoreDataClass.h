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
#import "VideoItemMO+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlaylistMO : NSManagedObject

+ (NSString*)entityName;
+ (NSString*)recentPlaylistName;

// Creation
+ (PlaylistMO*)getEmptyWithContext: (NSManagedObjectContext*) context;
+ (PlaylistMO*)playlistWithName: (NSString*) name withContext: (NSManagedObjectContext*) context;

// Editing
- (BOOL)rename: (NSString*) name;
- (BOOL)addVideoItem: (VideoItemMO*) item;
- (BOOL)deleteVideoItem: (VideoItemMO*) item;

// Accessors
- (NSArray<VideoItemMO*>*)getVideoItems;
- (VideoItemMO*)getFirstVideoItem;
- (BOOL)containsVideoItem: (VideoItemMO*) item;

// Instance Accessors
+ (NSArray<PlaylistMO*>*)getPlaylistsWithContext: (NSManagedObjectContext*) context;
+ (PlaylistMO*)getRecentPlaylistWithContext: (NSManagedObjectContext*) context;
+ (PlaylistMO*)getPlaylistForName: (NSString*) name withContext: (NSManagedObjectContext*) context;

// Basic
- (BOOL)saveObject;
- (BOOL)deleteObject;




@end

NS_ASSUME_NONNULL_END

#import "PlaylistMO+CoreDataProperties.h"
