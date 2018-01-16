//
//  MEKWebVideoParserProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoItemMO+CoreDataClass.h"

@protocol MEKWebVideoParserInputProtocol <NSObject>

@required
- (void)loadVideoItem: (VideoItemMO*) item;

@end

@protocol MEKWebVideoParserOutputProtocol <NSObject>

@required
- (void)webVideoParser: (id<MEKWebVideoParserInputProtocol>) parser didLoadItem: (VideoItemMO*) item;

@end
