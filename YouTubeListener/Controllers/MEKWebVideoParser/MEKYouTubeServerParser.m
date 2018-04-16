//
//  MEKYouTubeServerParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKYouTubeServerParser.h"
#import "VideoItemMO+CoreDataClass.h"

@implementation MEKYouTubeServerParser

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

- (NSURL *)generateUrlForVideoItem:(VideoItemMO *)item
{
    NSString *urlString = [NSString stringWithFormat:@"http://mek-youtube-server.herokuapp.com/info/%@", item.videoId];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (BOOL)parseQueryContent: (NSString*) content toVideoItem:(VideoItemMO **)itemRef
{
    VideoItemMO *item = *itemRef;

    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    NSMutableDictionary *urls = [NSMutableDictionary new];
    NSMutableDictionary *sizes = [NSMutableDictionary new];

    NSDictionary *urlsDict = json[@"urls"];
    for (NSString *key in urlsDict)
    {
        NSString *urlString = urlsDict[key];
        urls[@([key integerValue])] = [NSURL URLWithString:urlString];

        NSDictionary *params = [self dictionaryWithQueryString:[urlString componentsSeparatedByString:@"?"][1]];
        sizes[@([key integerValue])] = @([params[@"clen"] doubleValue] / 1024 / 1024);
    }

    item.title = json[@"title"];
    item.author = json[@"author"];
    item.length = ((NSString*)json[@"length_seconds"]).doubleValue;
    item.thumbnailSmall = [NSURL URLWithString:json[@"thumbnail_small"]];
    item.thumbnailBig = [NSURL URLWithString:json[@"thumbnail_large"]];
    item.urls = urls;
    item.sizes = sizes;

    return YES;
}

@end
