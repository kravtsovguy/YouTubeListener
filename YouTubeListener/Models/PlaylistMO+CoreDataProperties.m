//
//  PlaylistMO+CoreDataProperties.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 13/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "PlaylistMO+CoreDataProperties.h"

@implementation PlaylistMO (CoreDataProperties)

+ (NSFetchRequest<PlaylistMO *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Playlist"];
}

@dynamic name;
@dynamic items;

@end
