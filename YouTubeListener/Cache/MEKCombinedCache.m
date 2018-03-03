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
    memoryCache.countLimit = 20;

    MEKFileCache *fileCache = [[MEKFileCache alloc] init];
    fileCache.countLimit = 100;
    fileCache.sizeBytesLimit = 10 * 1024 * 1024;
    fileCache.bufferCountLimit = 20;
    fileCache.bufferSizeBytesLimit = 5 * 1024 * 1024;
    
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
    [self.primaryCache setObject:object forKey:key];
    [self.secondaryCache setObject:object forKey:key];
}

- (void)removeAllObjects
{
    [self.primaryCache removeAllObjects];
    [self.secondaryCache removeAllObjects];
}

@end
