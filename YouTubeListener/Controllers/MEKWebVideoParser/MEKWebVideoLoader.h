//
//  MEKWebVideoParser.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEKWebVideoLoaderProtocol.h"
#import "MEKWebVideoParserProtocol.h"

@interface MEKWebVideoLoader : NSObject  <MEKWebVideoLoaderInputProtocol>

@property (nonatomic, weak) id<MEKWebVideoLoaderOutputProtocol> output;

+ (id<MEKWebVideoParserProtocol>)parserForURL: (NSURL*) url;

@end
