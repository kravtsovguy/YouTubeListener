//
//  YouTubeParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "YouTubeParser.h"
#import "AppDelegate.h"
#import "MEKDownloadController.h"

@interface YouTubeParser() <MEKDownloadControllerDelegate>

@property (nonatomic, strong) VideoItemMO *item;
@property (nonatomic, strong) MEKDownloadController *downloadController;

@end

@interface YouTubeParser()

-(void) loadVideoItemFromUrl: (NSURL*) url;

@end

@implementation YouTubeParser

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _downloadController = [MEKDownloadController new];
        [_downloadController configurateUrlSessionWithParams:nil backgroundMode:NO];
        _downloadController.delegate = self;
    }
    return self;
}

- (void)loadVideoItem:(VideoItemMO *)item
{
    self.item = item;
    [self loadVideoItemFromUrl:item.originURL];
}

- (void)loadVideoItemFromUrl:(NSURL *)url
{
    NSString *videoURL = url.absoluteString;
    NSString *code;
    
    if ([videoURL containsString:@"youtube"])
        code = [[videoURL componentsSeparatedByString:@"="][1] componentsSeparatedByString:@"&"][0];
    else
        code = [videoURL componentsSeparatedByString:@"youtu.be/"][1];
    
    NSURL *infoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtube.com/get_video_info?video_id=%@&hl=ru_RU", code]];
    
    [self.downloadController downloadDataFromURL:infoUrl forKey:code withParams:nil];
}

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSString *content = [NSString stringWithContentsOfFile:url.path encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *info = [self parseQueryContent:content];
    
    VideoItemMO *item = self.item;
    
    item.videoId = key;
    item.title = info[@"title"];
    item.author = info[@"author"];
    item.length = ((NSString*)info[@"length_seconds"]).doubleValue;
    item.thumbnailSmall = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", item.videoId]];
    item.thumbnailBig = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", item.videoId]];
    item.urls = info[@"urls"];
    item.sizes = info[@"sizes"];
    item.added = [NSDate new];

    [item saveObject];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(youtubeParserItemDidLoad:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate youtubeParserItemDidLoad:item];
        });
    }
}

- (NSDictionary*) parseQueryContent: (NSString*) content
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSDictionary *info = [self dictionaryWithQueryString:content];
    result[@"title"] = info[@"title"];
    result[@"author"] = info[@"author"];
    result[@"length_seconds"] = info[@"length_seconds"];
    result[@"view_count"] = info[@"view_count"];
//    result[@"thumbnail_big"] = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", self.currentVideoId]];
//    result[@"thumbnail_small"] = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", self.currentVideoId]];
    result[@"urls"] = [NSMutableDictionary new];
    result[@"sizes"] = [NSMutableDictionary new];
    
    NSMutableDictionary *urls = result[@"urls"];
    NSMutableDictionary *sizes = result[@"sizes"];
    
    NSArray *streamQueries = [[info[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","] mutableCopy];
    for (NSString *streamQuery in streamQueries)
    {
        NSDictionary *params = [self dictionaryWithQueryString:streamQuery];
        urls[@([params[@"itag"] integerValue])] = [NSURL URLWithString:params[@"url"]];
        
        NSDictionary *urlParams = [self dictionaryWithQueryString:params[@"url"]];
        sizes[@([params[@"itag"] integerValue])] = @([urlParams[@"clen"] integerValue]);
    }
    
    return result;
}

- (NSDictionary*) dictionaryWithQueryString: (NSString*) string
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSArray *fields = [string componentsSeparatedByString:@"&"];
    for (NSString *field in fields) {
        NSArray *pair = [field componentsSeparatedByString:@"="];
        if (pair.count == 2) {
            NSString *key = pair[0];
            NSString *value = [[pair[1] stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            dictionary[key] = value;
        }
    }
    return dictionary;
}

@end
