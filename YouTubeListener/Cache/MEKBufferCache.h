//
//  MEKBufferCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 04/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCacheProtocol.h"

@class MEKBufferCache;

@protocol MEKBufferCacheDelegate

- (void)bufferCacheDidFilled: (MEKBufferCache *)bufferCache;

@end

@interface MEKBufferCache : NSObject <MEKCacheInputProtocol>

@property (nonatomic, weak) id<MEKBufferCacheDelegate> delegate;

@property (nonatomic, assign) NSUInteger totalCostLimit;
@property (nonatomic, assign) NSUInteger countLimit;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, id> *buffer;

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost;

@end
