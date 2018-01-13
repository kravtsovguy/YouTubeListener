//
//  VideoItemMO+CoreDataProperties.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 13/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "VideoItemMO+CoreDataProperties.h"

@implementation VideoItemMO (CoreDataProperties)

+ (NSFetchRequest<VideoItemMO *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"VideoItem"];
}

@dynamic added;
@dynamic author;
@dynamic length;
@dynamic thumbnailBig;
@dynamic thumbnailSmall;
@dynamic title;
@dynamic videoId;
@dynamic urls;

@end
