//
//  PlaylistMO+CoreDataProperties.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 13/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "PlaylistMO+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PlaylistMO (CoreDataProperties)

+ (NSFetchRequest<PlaylistMO *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSArray *items;

@end

NS_ASSUME_NONNULL_END
