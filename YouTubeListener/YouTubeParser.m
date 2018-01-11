//
//  YouTubeParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "YouTubeParser.h"
#import "NetworkService.h"
#import "AppDelegate.h"

@interface YouTubeParser() <NetworkServiceOutputProtocol>

@property (nonatomic, strong) NSString *currentVideoId;
@property (nonatomic, strong) NetworkService *networkServiceInfo;
@property (nonatomic, readonly) MEKVideoItemsController *controller;

@end

@implementation YouTubeParser

- (instancetype)init
{
    self = [super init];
    if (self) {
        _networkServiceInfo = [NetworkService new];
        [_networkServiceInfo configurateUrlSessionWithParams:nil];
        _networkServiceInfo.output = self;
    }
    return self;
}

-(MEKVideoItemsController *)controller
{
    UIApplication *application = [UIApplication sharedApplication];
    MEKVideoItemsController *controller = ((AppDelegate*)(application.delegate)).videoItemsController;
    
    return controller;
}

-(void) loadVideoInfo: (NSString*) videoURL
{
    NSString *code;
    
    if ([videoURL containsString:@"youtube"])
        code = [[videoURL componentsSeparatedByString:@"="][1] componentsSeparatedByString:@"&"][0];
    else
        code = [videoURL componentsSeparatedByString:@"youtu.be/"][1];
    
    self.currentVideoId = code;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtube.com/get_video_info?video_id=%@&hl=ru_RU", code]];
    [self.networkServiceInfo loadDataFromURL:url];
}

-(void) loadingIsDoneWithDataRecieved:(NSData *)dataRecieved withTask:(NSURLSessionDownloadTask *)task withService:(id<NetworkServiceInputProtocol>)service
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *content = [[NSString alloc] initWithData:dataRecieved encoding:NSUTF8StringEncoding];
        NSDictionary *info = [self parseQueryContent:content];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(infoDidLoad:forVideo:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate infoDidLoad:info forVideo:self.currentVideoId];
            });
        }
    });
}

-(NSDictionary*) parseQueryContent: (NSString*) content
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSDictionary *info = [self dictionaryWithQueryString:content];
    result[@"title"] = info[@"title"];
    result[@"author"] = info[@"author"];
    result[@"length_seconds"] = info[@"length_seconds"];
    result[@"view_count"] = info[@"view_count"];
    result[@"thumbnail_big"] = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", self.currentVideoId]];
    result[@"thumbnail_small"] = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", self.currentVideoId]];
    result[@"urls"] = [NSMutableDictionary new];
    NSMutableDictionary *urls = result[@"urls"];
    
    NSArray *streamQueries = [[info[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","] mutableCopy];
    for (NSString *streamQuery in streamQueries)
    {
        NSDictionary *params = [self dictionaryWithQueryString:streamQuery];
        urls[@([params[@"itag"] integerValue])] = [NSURL URLWithString:params[@"url"]];
    }
    
    VideoItemMO *item = [self.controller getEmptyVideoItem];
    item.videoId = info[@"vid"];
    item.title = info[@"title"];
    item.author = info[@"author"];
    item.length = ((NSString*)info[@"length_seconds"]).doubleValue;
    item.thumbnailSmall = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", item.videoId]];
    item.thumbnailBig = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", item.videoId]];
    item.urls = result[@"urls"];
    item.added = [NSDate new];
    
    return result;
}

-(NSDictionary*) dictionaryWithQueryString: (NSString*) string
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
