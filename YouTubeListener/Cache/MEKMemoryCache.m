//
//  MEKMemoryCache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKMemoryCache.h"

@interface MEKMemoryCache ()

@end

@implementation MEKMemoryCache

- (instancetype)init
{
    NSCache *cache = [[NSCache alloc] init];
    return [self initWithCache:cache];
}

- (instancetype)initWithCache:(NSCache *)cache
{
    self = [super init];
    if (self)
    {
        _cache = cache;
        
        self.countLimit = 200;
        self.totalCostLimit = 100 * 1024 * 1024;
    }
    return self;
}

- (id)objectForKey:(NSString *)key
{
    return [self.cache objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost
{
    if (object)
    {
        [self.cache setObject:object forKey:key cost:cost];
    }
    else
    {
        [self.cache removeObjectForKey:key];
    }
}

- (void)removeAllObjects
{
    [self.cache removeAllObjects];
}

- (void)setCountLimit:(NSUInteger)countLimit
{
    self.cache.countLimit = countLimit;
}

- (NSUInteger)countLimit
{
    return self.cache.countLimit;
}

- (void)setTotalCostLimit:(NSUInteger)totalCostLimit
{
    self.cache.totalCostLimit = totalCostLimit;
}

- (NSUInteger)totalCostLimit
{
    return self.cache.totalCostLimit;
}

@end
