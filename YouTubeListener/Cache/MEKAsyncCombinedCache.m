//
//  MEKAsyncCombinedCache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 04/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKAsyncCombinedCache.h"

@implementation MEKAsyncCombinedCache

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (id)objectForKey:(NSString *)key
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        id primaryObject = [self.primaryCache objectForKey:key];
        if (primaryObject)
        {
            [self.delegate asyncCombinedCache:self primaryObjectFound:primaryObject forKey:key fromCache:self.primaryCache];
        }
        else
        {
            id secondaryObject = [self.secondaryCache objectForKey:key];
            if (secondaryObject)
            {
                [self setObject:secondaryObject forKey:key];
            }
            else
            {
                [self.delegate asyncCombinedCache:self objectNotFoundForKey:key];
            }
        }
    });

    return nil;
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)secondaryObject forKey:(NSString *)key withCost:(NSUInteger)cost
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        //----
        id primaryObject = secondaryObject;
        if ([self.delegate respondsToSelector:@selector(asyncCombinedCache:primaryObjectFromSecondaryObject:)])
        {
            primaryObject = [self.delegate asyncCombinedCache:self primaryObjectFromSecondaryObject:secondaryObject];
        }

        //-----
        id<MEKCacheInputProtocol> cache;
        cache = [self.secondaryCache objectForKey:key] ? self.secondaryCache : cache;
        cache = [self.primaryCache objectForKey:key] ? self.primaryCache : cache;
        [self.delegate asyncCombinedCache:self primaryObjectFound:primaryObject forKey:key fromCache:cache];

        //----
        [self.primaryCache setObject:primaryObject forKey:key withCost:cost];
        [self.secondaryCache setObject:secondaryObject forKey:key withCost:cost];
    });
}

- (void)removeAllObjects
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        [super removeAllObjects];
    });
}

@end
