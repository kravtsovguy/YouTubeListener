//
//  MEKCacheProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MEKCacheInputProtocol <NSObject>

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
- (void)removeAllObjects;

@end

@protocol MEKCacheOutputProtocol <NSObject>

@optional
- (void)cache:(id<MEKCacheInputProtocol> *)cache willEvictObject:(id)object;

@end
