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

extern NSString * _Nonnull const VideoItemHTTPLiveStreaming;

typedef NS_ENUM (NSUInteger, VideoItemQuality) {
    VideoItemQualitySmall144  = 17,
    VideoItemQualitySmall240  = 36,
    VideoItemQualityMedium360 = 18,
    VideoItemQualityHD720 = 22,
};

NS_ASSUME_NONNULL_BEGIN

@class PlaylistMO;
@class VideoItemMO;

@interface VideoItemMO : NSManagedObject

+ (NSArray<NSNumber*>*)getAllQualities;
+ (NSString*)getQualityString: (VideoItemQuality) quality;

+ (NSString*)entityName;

// Creation
+ (VideoItemMO*)connectedEntityWithContext: (NSManagedObjectContext*) context;
+ (VideoItemMO*)disconnectedEntityWithContext: (NSManagedObjectContext*) context;

// Instance Accessors
+ (NSArray<VideoItemMO*>*)executeFetchRequest: (NSFetchRequest*) request withContext: (NSManagedObjectContext*) context;
+ (VideoItemMO*)getVideoItemForURL: (NSURL*) videoURL withContext: (NSManagedObjectContext*) context;
+ (VideoItemMO*)getVideoItemForId: (NSString*) videoId withContext: (NSManagedObjectContext*) context;
+ (NSArray<VideoItemMO*>*)getVideoItemsWithContext: (NSManagedObjectContext*) context;
+ (NSArray<VideoItemMO*>*)addedVideoItemsWithContext: (NSManagedObjectContext*) context;
+ (NSArray<VideoItemMO*>*)videoItemsFromJSON:(NSArray<NSDictionary *> *)videosJSON withContext: (NSManagedObjectContext*) context;

// Basic
- (void)setupWithDictionary: (NSDictionary*) json;
- (NSDictionary *)toDictionary;
- (BOOL)saveObject;
- (BOOL)deleteObject;

// History
+ (NSArray<VideoItemMO*>*)historyVideoItemsFromUserDefaults:(NSUserDefaults *)userDefaults withContext: (NSManagedObjectContext*) context;
+ (void)removeHistoryForUserDefaults: (NSUserDefaults *)userDefaults;
- (void)addToHistoryForUserDefaults: (NSUserDefaults *)userDefaults;

// Library
- (BOOL)addedToLibrary: (NSManagedObjectContext*) context;
- (void)addToLibrary: (NSManagedObjectContext*) context;
- (void)removeFromLibrary: (NSManagedObjectContext *)context;

// Downloading
- (BOOL)saveTempPathURL: (NSURL*) url withQuality: (VideoItemQuality) quality;
- (BOOL)removeAllDownloads;
- (BOOL)removeDownloadWithQuality: (VideoItemQuality) quality;
- (BOOL)hasDownloadedWithQuality: (VideoItemQuality) quality;
- (BOOL)hasDownloaded;
- (VideoItemQuality)downloadedQuality;
- (NSDictionary*)downloadedURLs;
- (NSDictionary*)downloadedSizes;

@end

NS_ASSUME_NONNULL_END

#import "VideoItemMO+CoreDataProperties.h"
