//
//  MEKBufferCache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 04/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKBufferCache.h"

@interface MEKBufferCache()

@property (nonatomic, assign) NSUInteger bufferCost;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *bufferCostDictionary;
@property (nonatomic, copy) NSDictionary<NSString *, id> *buffer;

@end

@implementation MEKBufferCache

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _buffer = @{}.mutableCopy;
        _bufferCostDictionary = @{}.mutableCopy;

        self.countLimit = 50;
        self.totalCostLimit = 5 * 1024 * 1024;
    }
    return self;
}

- (NSUInteger)bufferCount
{
    return self.buffer.count;
}

- (NSDictionary<NSString *,id> *)dictionary
{
    return self.buffer.copy;
}

- (id)objectForKey:(NSString *)key
{
    return self.buffer[key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost
{
    id currentObject = self.buffer[key];
    NSMutableDictionary *buffer = self.buffer.mutableCopy;
    NSMutableDictionary *bufferCostDictionary = self.bufferCostDictionary.mutableCopy;

    if (object)
    {
        if (currentObject)
        {
            [self setObject:nil forKey:key];
        }

        buffer[key] = object;
        bufferCostDictionary[key] = @(cost);
        self.bufferCost += cost;

        [self p_checkBuffer];
    }
    else
    {
        if (!currentObject)
        {
            return;
        }

        self.bufferCost -= self.bufferCostDictionary[key].unsignedIntegerValue;
        buffer[key] = nil;
        bufferCostDictionary[key] = nil;
    }

    self.buffer = buffer;
    self.bufferCostDictionary = bufferCostDictionary;
}

- (void)removeAllObjects
{
    self.buffer = @{}.mutableCopy;
    self.bufferCostDictionary = @{}.mutableCopy;
    self.bufferCost = 0;
}

- (void)p_checkBuffer
{
    BOOL isOverCount = self.countLimit > 0 && self.bufferCount >= self.countLimit;
    BOOL isOverSize = self.totalCostLimit > 0 && self.bufferCost >= self.totalCostLimit;

    if (isOverCount || isOverSize)
    {
        [self.delegate bufferCacheDidFilled:self];
        [self removeAllObjects];
    }
}

@end
