//
//  MEKDefaultParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDefaultParser.h"

@implementation MEKDefaultParser

- (NSString*)generateIdForVideoItem: (VideoItemMO*) item
{
    NSString *path = [self generateUrlForVideoItem:item].absoluteString;
    NSString *videoId = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    return videoId;
}

- (NSURL *)generateUrlForVideoItem:(VideoItemMO *)item
{
    return item.originURL;
}

- (NSURLRequest *)generateRequestForVideoItem:(VideoItemMO *)item
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[self generateUrlForVideoItem:item]];
    return request;
}

- (BOOL)parseQueryContent: (NSString*) content toVideoItem:(VideoItemMO **)itemRef
{
    return NO;
}

- (BOOL)shouldUseWebBrowser
{
    return NO;
}

@end
