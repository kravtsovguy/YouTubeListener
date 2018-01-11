//
//  VideoItemMO+CoreDataProperties.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "VideoItemMO+CoreDataProperties.h"

@implementation VideoItemMO (CoreDataProperties)

+ (NSFetchRequest<VideoItemMO *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"VideoItem"];
}

@dynamic title;
@dynamic author;
@dynamic length;
@dynamic thumbnailSmall;
@dynamic thumbnailBig;
@dynamic videoId;
@dynamic added;

@end
