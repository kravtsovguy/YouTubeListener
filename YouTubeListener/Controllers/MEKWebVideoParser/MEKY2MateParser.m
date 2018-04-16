//
//  MEKY2MateParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKY2MateParser.h"
#import "VideoItemMO+CoreDataClass.h"

@implementation MEKY2MateParser

#pragma mark - Private

- (NSDictionary*)dictionaryWithQueryString: (NSString*) string
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSArray *fields = [string componentsSeparatedByString:@"&"];
    for (NSString *field in fields)
    {
        NSArray *pair = [field componentsSeparatedByString:@"="];
        if (pair.count == 2)
        {
            NSString *key = pair[0];
            NSString *value = [[pair[1] stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            dictionary[key] = value;
        }
    }
    return dictionary;
}

#pragma mark - MEKWebVideoParserProtocol

- (NSString*)generateIdForVideoItem: (VideoItemMO*) item
{
    NSString *videoURL = item.originURL.absoluteString;
    NSString *code;

    if ([videoURL containsString:@"youtube"])
    {
        code = [[videoURL componentsSeparatedByString:@"="][1] componentsSeparatedByString:@"&"][0];
    }
    else
    {
        code = [videoURL componentsSeparatedByString:@"youtu.be/"][1];
    }

    return code;
}

- (NSURLRequest *)generateRequestForVideoItem:(VideoItemMO *)item
{
    NSString *encodedURL = [item.originURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *paramsString = [NSString stringWithFormat:@"url=%@&ajax=1", encodedURL];
    NSData *data = [paramsString dataUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:@"https://y2mate.com/analyze/ajax"];
    NSMutableURLRequest *request = [[NSURLRequest alloc] initWithURL:url].mutableCopy;

    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];

    return request;
}

//- (NSURL*)generateUrlForVideoItem: (VideoItemMO*)item
//{
//    NSURL *infoUrl = [NSURL URLWithString:@"https://y2mate.com/analyze/ajax"];
//    return infoUrl;
//}

- (NSString*)contentOfElement: (NSString*) element WithName: (NSString*) name
{
    NSRange rangeFirst = [element rangeOfString:[NSString stringWithFormat:@"<%@", name] options:0];
    NSRange rangeSecond = [element  rangeOfString:[NSString stringWithFormat:@"/%@>", name] options:0];

    NSString *content = [element substringWithRange:NSMakeRange(rangeFirst.location, rangeSecond.location - rangeFirst.location)];
    return content;
}

- (NSString*)valueOfElement: (NSString*) element withName: (NSString*) name
{
    NSString *content = [self contentOfElement:element WithName:name];

    NSRange rangeFirst = [content rangeOfString:@">" options:0];
    NSRange rangeSecond = [content rangeOfString:@"<" options:NSBackwardsSearch];
    NSString *value = [content substringWithRange:NSMakeRange(rangeFirst.location + rangeFirst.length, rangeSecond.location - (rangeFirst.location + rangeFirst.length))];
    return value;
}

- (BOOL)parseQueryContent: (NSString*) content toVideoItem:(VideoItemMO **)itemRef
{
    VideoItemMO *item = *itemRef;

    NSArray *strings = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    NSMutableDictionary *urls = [NSMutableDictionary new];
    NSMutableDictionary *sizes = [NSMutableDictionary new];
    NSArray *attributes = [content componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString *attribute in attributes)
    {
        NSRange rangeFirst = [attribute rangeOfString:@"data-vlink=\"" options:0];
        NSRange rangeSecond = [attribute rangeOfString:@"\">" options:NSBackwardsSearch];

        if (rangeFirst.location == NSNotFound || rangeSecond.location == NSNotFound)
        {
            continue;
        }

        NSString *urlString = [attribute substringWithRange:NSMakeRange(rangeFirst.location + rangeFirst.length, rangeSecond.location - (rangeFirst.location + rangeFirst.length))];
        NSString *paramsString = [urlString componentsSeparatedByString:@"?"][1];
        NSDictionary *params = [self dictionaryWithQueryString:paramsString];

        urls[@([params[@"itag"] integerValue])] = [NSURL URLWithString:urlString];
        sizes[@([params[@"itag"] integerValue])] = @([params[@"clen"] integerValue] / 1000 / 1000);

        if (item.length == 0)
        {
            item.length = ((NSString*)params[@"dur"]).doubleValue;
        }
    }

    item.title = [self valueOfElement:strings[12 + 1] withName:@"b"];
    item.author = [self valueOfElement:strings[14 + 1] withName:@"a"];
    item.thumbnailSmall = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", item.videoId]];
    item.thumbnailBig = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", item.videoId]];
    item.urls = urls;
    item.sizes = sizes;

    return YES;
}

@end
