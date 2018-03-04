//
//  MEKAsyncCombinedCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 04/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCombinedCache.h"

@class MEKAsyncCombinedCache;

@protocol MEKAsyncCombinedCacheDelegate <NSObject>

- (id)asyncCombinedCache: (MEKAsyncCombinedCache *)combinedCache primaryObjectFromSecondaryObject: (id)secondaryObject;
- (void)asyncCombinedCache: (MEKAsyncCombinedCache *)combinedCache objectNotFoundForKey: (NSString *)key;
- (void)asyncCombinedCache: (MEKAsyncCombinedCache *)combinedCache primaryObjectFound: (id)primaryObject forKey: (NSString *)key fromCache: (id<MEKCacheInputProtocol>)cache;

@end

@interface MEKAsyncCombinedCache : MEKCombinedCache

@property (nonatomic, weak) id<MEKAsyncCombinedCacheDelegate> delegate;

@end
