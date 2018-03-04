//
//  MEKCombinedCache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCombinedCache.h"
#import "MEKMemoryCache.h"
#import "MEKFileCache.h"

@interface MEKCombinedCache ()

@end

@implementation MEKCombinedCache

- (instancetype)init
{
    MEKMemoryCache *memoryCache = [[MEKMemoryCache alloc] init];
    MEKFileCache *fileCache = [[MEKFileCache alloc] init];
    
    return [self initWithPrimaryCache:memoryCache withSecondaryCache:fileCache];
}

- (instancetype)initWithPrimaryCache:(id<MEKCacheInputProtocol>)primaryCache withSecondaryCache:(id<MEKCacheInputProtocol>)secondaryCache
{
    self = [super init];
    if (self)
    {
        _primaryCache = primaryCache;
        _secondaryCache = secondaryCache;
    }
    return self;
}

- (id)objectForKey:(NSString *)key
{
    id object = [self.primaryCache objectForKey:key];

    if (!object)
    {
        object = [self.secondaryCache objectForKey:key];
        [self.primaryCache setObject:object forKey:key];
    }

    return object;
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost
{
    [self.primaryCache setObject:object forKey:key withCost:cost];
    [self.secondaryCache setObject:object forKey:key withCost:cost];
}

- (void)removeAllObjects
{
    [self.primaryCache removeAllObjects];
    [self.secondaryCache removeAllObjects];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithPrimaryCache:self.primaryCache withSecondaryCache:self.secondaryCache];
}

@end
