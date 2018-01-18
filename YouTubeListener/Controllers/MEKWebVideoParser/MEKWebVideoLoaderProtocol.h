//
//  MEKWebVideoLoaderProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoItemMO+CoreDataClass.h"

@protocol MEKWebVideoLoaderInputProtocol <NSObject>

@required
- (BOOL)loadVideoItem: (VideoItemMO*) item;

@end

@protocol MEKWebVideoLoaderOutputProtocol <NSObject>

@required
- (void)webVideoLoader: (id<MEKWebVideoLoaderInputProtocol>) loader didLoadItem: (VideoItemMO*) item;

@end
