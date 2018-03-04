//
//  MEKBufferCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 04/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCacheProtocol.h"
#import "MEKBaseCache.h"

@class MEKBufferCache;

@protocol MEKBufferCacheDelegate <NSObject>

- (void)bufferCacheDidFilled: (MEKBufferCache *)bufferCache;

@end

@interface MEKBufferCache : MEKBaseCache <MEKCacheInputProtocol>

@property (nonatomic, weak) id<MEKBufferCacheDelegate> delegate;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *buffer;

@end
