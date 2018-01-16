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

typedef NS_ENUM (NSUInteger, VideoItemQuality) {
    VideoItemQualitySmall144  = 17,
    VideoItemQualitySmall240  = 36,
    VideoItemQualityMedium360 = 18,
    VideoItemQualityHD720 = 22,
};

NS_ASSUME_NONNULL_BEGIN

@interface VideoItemMO : NSManagedObject

+ (NSString*)entityName;

// Creation
+ (VideoItemMO*)getEmptyWithContext: (NSManagedObjectContext*) context;

// Instance Accessors
+ (VideoItemMO*)getVideoItemForURL: (NSURL*) videoURL withContext: (NSManagedObjectContext*) context;
+ (VideoItemMO*)getVideoItemForId: (NSString*) videoId withContext: (NSManagedObjectContext*) context;
+ (NSArray<VideoItemMO*>*)getVideoItemsWithContext: (NSManagedObjectContext*) context;

// Basic
- (BOOL)saveObject;
- (BOOL)deleteObject;

// Downloading
- (BOOL)saveTempPathURL: (NSURL*) url withQuality: (VideoItemQuality) quality;
- (BOOL)removeDownloadAll;
- (BOOL)removeDownloadWithQuality: (VideoItemQuality) quality;
- (BOOL)hasDownloadedWithQuality: (VideoItemQuality) quality;
- (BOOL)hasDownloaded;
- (NSDictionary*)downloadedURLs;

@end

NS_ASSUME_NONNULL_END

#import "VideoItemMO+CoreDataProperties.h"
