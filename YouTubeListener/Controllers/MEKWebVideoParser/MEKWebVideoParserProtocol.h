//
//  MEKWebVideoParserProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 18/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MEKLoadType) {
    MEKLoadNone,
    MEKLoadURL,
    MEKLoadWebBrowser,
};

@class VideoItemMO;

@protocol MEKWebVideoParserProtocol <NSObject>

@required
@property (nonatomic, readonly) MEKLoadType loadType;

- (NSString*)generateIdForVideoItem: (VideoItemMO*) item;
- (NSURL*)generateUrlForVideoItem: (VideoItemMO*)item;
- (NSURLRequest*)generateRequestForVideoItem: (VideoItemMO*)item;
- (BOOL)parseQueryContent: (NSString*) content toVideoItem: (VideoItemMO*) item;

@end
