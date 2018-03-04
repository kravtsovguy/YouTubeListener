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
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *bufferCostDictionary;
@property (nonatomic, strong) NSDictionary<NSString *, id> *buffer;

@end

@implementation MEKBufferCache

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _buffer = @{}.mutableCopy;
        _bufferCostDictionary = @{}.mutableCopy;
    }
    return self;
}

- (NSDictionary<NSString *,id> *)dictionary
{
    return self.buffer.copy;
}

- (id)objectForKey:(NSString *)key
{
    id object = self.buffer[key];
    return object;
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost
{
    id currentObject = self.buffer[key];
    NSMutableDictionary *buffer = self.buffer.mutableCopy;

    if (object)
    {
        if (currentObject)
        {
            [self setObject:nil forKey:key withCost:cost];
        }

        buffer[key] = object;
        self.buffer = buffer;

        self.bufferCostDictionary[key] = @(cost);
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
        self.buffer = buffer;

        self.bufferCostDictionary[key] = nil;
    }
}

- (void)removeAllObjects
{
    self.buffer = @{}.mutableCopy;
    self.bufferCostDictionary = @{}.mutableCopy;
    self.bufferCost = 0;
}

- (void)p_checkBuffer
{
    BOOL isOverCount = self.countLimit > 0 && self.buffer.count > self.countLimit;
    BOOL isOverSize = self.totalCostLimit > 0 && self.bufferCost > self.totalCostLimit;

    if (isOverCount || isOverSize)
    {
        [self.delegate bufferCacheDidFilled:self];
        [self removeAllObjects];
    }
}

@end
