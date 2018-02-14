//
//  MEKWebVideoParserProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 18/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoItemMO+CoreDataClass.h"

@protocol MEKWebVideoParserProtocol <NSObject>

@required
- (NSString*)generateIdForVideoItem: (VideoItemMO*) item;
- (NSURL*)generateUrlForVideoItem: (VideoItemMO*)item;
- (NSURLRequest*)generateRequestForVideoItem: (VideoItemMO*)item;
- (BOOL)parseQueryContent: (NSString*) content toVideoItem: (VideoItemMO**) item;
- (BOOL)shouldUseWebBrowser;

@end
