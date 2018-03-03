//
//  MEKMemoryCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCacheProtocol.h"

@interface MEKMemoryCache : NSObject<MEKCacheInputProtocol>

@property (nonatomic, readonly) NSCache *cache;
@property (nonatomic, assign) NSUInteger totalCostLimit;
@property (nonatomic, assign) NSUInteger countLimit;

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost;

- (instancetype)initWithCache: (NSCache *)cache;

@end
