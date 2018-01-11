//
//  PlaylistMO+CoreDataProperties.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//
//

#import "PlaylistMO+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PlaylistMO (CoreDataProperties)

+ (NSFetchRequest<PlaylistMO *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<VideoItemMO *> *items;

@end

@interface PlaylistMO (CoreDataGeneratedAccessors)

- (void)insertObject:(VideoItemMO *)value inItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx;
- (void)insertItems:(NSArray<VideoItemMO *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(VideoItemMO *)value;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray<VideoItemMO *> *)values;
- (void)addItemsObject:(VideoItemMO *)value;
- (void)removeItemsObject:(VideoItemMO *)value;
- (void)addItems:(NSOrderedSet<VideoItemMO *> *)values;
- (void)removeItems:(NSOrderedSet<VideoItemMO *> *)values;

@end

NS_ASSUME_NONNULL_END
