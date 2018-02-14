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

static NSString * _Nonnull const VideoItemHTTPLiveStreaming = @"HTTPLiveStreaming";

typedef NS_ENUM (NSUInteger, VideoItemQuality) {
    VideoItemQualitySmall144  = 17,
    VideoItemQualitySmall240  = 36,
    VideoItemQualityMedium360 = 18,
    VideoItemQualityHD720 = 22,
};

NS_ASSUME_NONNULL_BEGIN

@class PlaylistMO;
@class VideoItemMO;

@protocol MEKVideoItemDelegate <NSObject>

@optional
- (void)videoItemAddToPlaylist: (VideoItemMO*) item;
- (void)videoItemAddToPlaylist: (VideoItemMO*) item playlist: (PlaylistMO*) playlist;
- (void)videoItemDownload: (VideoItemMO*) item;
- (void)videoItemDownload: (VideoItemMO*) item withQuality: (VideoItemQuality) quality;
- (void)videoItemCancelDownload: (VideoItemMO*) item;

@end

@interface VideoItemMO : NSManagedObject

+ (NSArray<NSNumber*>*)getAllQualities;
+ (NSString*)getQualityString: (VideoItemQuality) quality;

+ (NSString*)entityName;

// Creation
+ (VideoItemMO*)getEmptyWithContext: (NSManagedObjectContext*) context;

// Instance Accessors
+ (NSArray<VideoItemMO*>*)executeFetchRequest: (NSFetchRequest*) request withContext: (NSManagedObjectContext*) context;
+ (VideoItemMO*)getVideoItemForURL: (NSURL*) videoURL withContext: (NSManagedObjectContext*) context;
+ (VideoItemMO*)getVideoItemForId: (NSString*) videoId withContext: (NSManagedObjectContext*) context;
+ (NSArray<VideoItemMO*>*)getVideoItemsWithContext: (NSManagedObjectContext*) context;
+ (NSArray<VideoItemMO*>*)getRecentVideoItemsWithContext: (NSManagedObjectContext*) context;

// Basic
- (BOOL)saveObject;
- (BOOL)deleteObject;

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
