//
//  MEKMemoryCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCacheProtocol.h"
#import "MEKBaseCache.h"

@interface MEKMemoryCache : MEKBaseCache <MEKCacheInputProtocol>

@property (nonatomic, readonly) NSCache *cache;

- (instancetype)initWithCache: (NSCache *)cache;

@end
