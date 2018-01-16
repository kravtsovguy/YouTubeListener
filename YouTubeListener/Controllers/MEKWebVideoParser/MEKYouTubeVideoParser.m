//
//  MEKYouTubeVideoParser.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "MEKYouTubeVideoParser.h"
#import "AppDelegate.h"
#import "MEKDownloadController.h"

@implementation MEKYouTubeVideoParser

- (NSString*)generateIdForVideoItem: (VideoItemMO*) item
{
    NSString *videoURL = item.originURL.absoluteString;
    NSString *code;
    
    if ([videoURL containsString:@"youtube"])
        code = [[videoURL componentsSeparatedByString:@"="][1] componentsSeparatedByString:@"&"][0];
    else
        code = [videoURL componentsSeparatedByString:@"youtu.be/"][1];
    
    return code;
}

- (NSURL*)generateUrlForVideoItem: (VideoItemMO*)item
{
    NSURL *infoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtube.com/get_video_info?video_id=%@&hl=ru_RU", item.videoId]];
    
    return infoUrl;
}

- (void)parseQueryContent: (NSString*) content forVideoItem: (VideoItemMO*) item
{
    NSDictionary *info = [self dictionaryWithQueryString:content];
    
    NSMutableDictionary *urls = [NSMutableDictionary new];
    NSMutableDictionary *sizes = [NSMutableDictionary new];

    NSArray *streamQueries = [[info[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","] mutableCopy];
    for (NSString *streamQuery in streamQueries)
    {
        NSDictionary *params = [self dictionaryWithQueryString:streamQuery];
        urls[@([params[@"itag"] integerValue])] = [NSURL URLWithString:params[@"url"]];
        
        NSDictionary *urlParams = [self dictionaryWithQueryString:params[@"url"]];
        sizes[@([params[@"itag"] integerValue])] = @([urlParams[@"clen"] integerValue]);
    }
    
    item.title = info[@"title"];
    item.author = info[@"author"];
    item.length = ((NSString*)info[@"length_seconds"]).doubleValue;
    item.thumbnailSmall = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", item.videoId]];
    item.thumbnailBig = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", item.videoId]];
    item.urls = urls;
    item.sizes = sizes;
    item.added = [NSDate new];
}

@end
