//
//  MEKSavefromParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKSavefromParser.h"
#import "VideoItemMO+CoreDataClass.h"

@implementation MEKSavefromParser

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


- (NSURL*)generateUrlForVideoItem: (VideoItemMO*)item
{
    NSURL *infoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://ru.savefrom.net/#url=%@", item.originURL.absoluteString]];
    return infoUrl;
}

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
    BOOL finish = [content containsString:@"redirector.googlevideo.com"];
    NSLog(@"finish load %@", @(finish));

    if (finish)
    {
        VideoItemMO *item = *itemRef;
        NSArray *lines = [content componentsSeparatedByString:@"><"];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", @"redirector.googlevideo.com"];
        NSArray *videos = [lines filteredArrayUsingPredicate:predicate];

        NSMutableDictionary *urls = [NSMutableDictionary new];
        NSMutableDictionary *sizes = [NSMutableDictionary new];

        for (NSString *video in videos)
        {
            NSString *urlString = [[video componentsSeparatedByString:@"href=\""][1] componentsSeparatedByString:@"\" "][0];
            urlString = [urlString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];

            NSString *paramsString = [urlString componentsSeparatedByString:@"?"][1];
            NSDictionary *params = [self dictionaryWithQueryString:paramsString];

            urls[@([params[@"itag"] integerValue])] = [NSURL URLWithString:urlString];
            sizes[@([params[@"itag"] integerValue])] = @([params[@"clen"] integerValue] / 1000 / 1000);
        }

        item.urls = urls;
        item.sizes = sizes;
    }

    return finish;
}

- (BOOL)shouldUseWebBrowser
{
    return YES;
}

@end
