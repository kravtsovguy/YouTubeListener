//
//  MEKCombinedCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCacheProtocol.h"

@interface MEKCombinedCache : NSObject <MEKCacheInputProtocol, NSCopying>

@property (nonatomic, strong, readonly) id<MEKCacheInputProtocol> primaryCache;
@property (nonatomic, strong, readonly) id<MEKCacheInputProtocol> secondaryCache;

- (instancetype)initWithPrimaryCache: (id<MEKCacheInputProtocol>)primaryCache withSecondaryCache: (id<MEKCacheInputProtocol>)secondaryCache;

@end
