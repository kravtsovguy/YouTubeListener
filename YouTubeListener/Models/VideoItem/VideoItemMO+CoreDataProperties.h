//
//  VideoItemMO+CoreDataProperties.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "VideoItemMO+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface VideoItemMO (CoreDataProperties)

+ (NSFetchRequest<VideoItemMO *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *added;
@property (nullable, nonatomic, copy) NSString *author;
@property (nonatomic) double length;
@property (nullable, nonatomic, copy) NSURL *thumbnailBig;
@property (nullable, nonatomic, copy) NSURL *thumbnailSmall;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, retain) NSDictionary *urls;
@property (nullable, nonatomic, copy) NSString *videoId;
@property (nullable, nonatomic, retain) NSDictionary *sizes;
@property (nullable, nonatomic, copy) NSURL *originURL;

@end

NS_ASSUME_NONNULL_END
