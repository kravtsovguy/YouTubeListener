//
//  VideoItemMO+CoreDataClass.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoItemMO : NSManagedObject

+ (NSString*)entityName;

// Creation
+ (VideoItemMO*)getEmptyWithContext: (NSManagedObjectContext*) context;

// Instance Accessors
+ (VideoItemMO*)getVideoItemForId: (NSString*) videoId withContext: (NSManagedObjectContext*) context;
+ (NSArray<VideoItemMO*>*)getVideoItemsWithContext: (NSManagedObjectContext*) context;

// Basic
- (BOOL)saveObject;
- (BOOL)deleteObject;

@end

NS_ASSUME_NONNULL_END

#import "VideoItemMO+CoreDataProperties.h"
