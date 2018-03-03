//
//  MEKFileCache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCacheProtocol.h"

@interface MEKFileCache : NSObject <MEKCacheInputProtocol>

@property (nonatomic, copy, readonly) NSString *directoryName;

@property (nonatomic, assign) NSUInteger countLimit;
@property (nonatomic, assign) NSUInteger sizeBytesLimit;

@property (nonatomic, assign) NSUInteger bufferCountLimit;
@property (nonatomic, assign) NSUInteger bufferSizeBytesLimit;

- (instancetype) initWithDirectoryName: (NSString *)directoryName;

@end
