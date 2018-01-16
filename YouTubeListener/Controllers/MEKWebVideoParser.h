//
//  MEKWebVideoParser.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEKWebVideoParserProtocol.h"
#import "MEKDownloadController.h"

@interface MEKWebVideoParser : NSObject  <MEKWebVideoParserInputProtocol, MEKDownloadControllerDelegate>

@property (nonatomic, weak) id<MEKWebVideoParserOutputProtocol> output;

- (NSDictionary*) dictionaryWithQueryString: (NSString*) string;

@end
