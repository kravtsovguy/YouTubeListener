//
//  MEKFileCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCacheProtocol.h"

@class MEKBufferCache;

@interface MEKFileCache : NSObject <MEKCacheInputProtocol>

@property (nonatomic, copy, readonly) NSString *directoryName;
@property (nonatomic, strong, readonly) MEKBufferCache *bufferCache;

@property (nonatomic, assign) NSUInteger countLimit;
@property (nonatomic, assign) NSUInteger sizeBytesLimit;

- (instancetype)initWithDirectoryName: (NSString *)directoryName;
- (instancetype)initWithDirectoryName: (NSString *)directoryName withBuffer: (MEKBufferCache *)buffer;

@end
