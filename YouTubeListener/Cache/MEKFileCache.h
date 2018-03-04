//
//  MEKFileCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCacheProtocol.h"
#import "MEKBaseCache.h"

@class MEKBufferCache;

@interface MEKFileCache : MEKBaseCache <MEKCacheInputProtocol>

@property (nonatomic, copy, readonly) NSString *directoryName;
@property (nonatomic, strong, readonly) MEKBufferCache *bufferCache;

- (instancetype)initWithDirectoryName: (NSString *)directoryName;
- (instancetype)initWithDirectoryName: (NSString *)directoryName withBuffer: (MEKBufferCache *)buffer;

@end
