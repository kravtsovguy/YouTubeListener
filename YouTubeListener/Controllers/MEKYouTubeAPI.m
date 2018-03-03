//
//  MEKYouTubeAPI.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 19/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKYouTubeAPI.h"
#import "MEKDownloadController.h"

static NSString * const MEKYouTubeAPI_KEY = @"AIzaSyBSvhGaZjoGncHa_gs7jr7DliFPTrtq1do";
static NSString * const MEKYouTubeAPI_BASE = @"https://www.googleapis.com/youtube/v3/";

typedef NS_ENUM(NSUInteger, MEKYouTubeActionType)
{
    MEKYouTubeActionSearch,
    MEKYouTubeActionVideo
};

@interface MEKYouTubeAPI () <MEKDownloadControllerDelegate>

@property (nonatomic, strong) MEKDownloadController *downloadController;

@end

@implementation MEKYouTubeAPI

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _downloadController = [[MEKDownloadController alloc] initWithBackgroundMode:NO];
        _downloadController.delegate = self;
    }
    return self;
}

- (void)loadDataForAction: (NSString*) action withParams: (NSDictionary*) params
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@?key=%@", MEKYouTubeAPI_BASE, action, MEKYouTubeAPI_KEY];

    for (NSString *key in params)
    {
        NSString *value = [params[key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        urlString = [urlString stringByAppendingFormat:@"&%@=%@", key, value];
    }

    NSURL *url = [NSURL URLWithString:urlString];

    [self.downloadController downloadDataFromURL:url forKey:action withParams:params];
}

- (void)loadDataForVideos: (NSArray*)videoIds
{
    NSString *action = @"videos";
    NSDictionary *params = @{
                         @"part" : @"snippet,contentDetails",
                         @"id" : [videoIds componentsJoinedByString:@","],
                         @"maxResults" : @(videoIds.count).stringValue
                         };

    [self loadDataForAction:action withParams:params];
}

- (void)searchVideosForQuery:(NSString *)query searchType:(MEKYouTubeSearchType)type maxResults:(NSUInteger)results pageToken:(NSString *)pageToken
{
    if (!query || query.length == 0)
    {
        return;
    }

    NSString *action = @"search";
    NSMutableDictionary *params = @{
                             @"part" : @"id",
                             @"type" : @"video",
                             @"order" : @"relevance",
                             @"maxResults" : @(results).stringValue,
                             @"pageToken" : pageToken ?: @""
                             }.mutableCopy;

    switch (type) {
        case MEKYouTubeSearchQuery:
            params[@"q"] = query;
            break;
        case MEKYouTubeSearchRelativeVideos:
            params[@"relatedToVideoId"] = query;
            break;
    }

    [self loadDataForAction:action withParams:params];
}

- (NSNumber*)parseISO8601Time:(NSString*)duration
{
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;

    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];

    while ([duration length] > 1)
    {
        duration = [duration substringFromIndex:1];

        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];

        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];

        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];

        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];

        if ([[duration substringToIndex:1] isEqualToString:@"H"])
        {
            hours = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"])
        {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"])
        {
            seconds = [durationPart intValue];
        }
    }

    NSInteger totalSeconds = 3600 * hours + 60 * minutes + seconds;

    return @(totalSeconds);
}

- (BOOL)downloadControllerDidFinish:(id<MEKDownloadControllerInputProtocol>)downloadController withTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *items = json[@"items"];

    if ([key isEqualToString:@"search"])
    {
        NSMutableArray *videoIds = @[].mutableCopy;

        for (NSDictionary *item in items)
        {
            NSString *videoId = item[@"id"][@"videoId"] ?: item[@"id"][@"id"];
            [videoIds addObject:videoId];
        }

        if ([self.delegate respondsToSelector:@selector(youTubeVideosDidSearch:nextPageToken:)])
        {
            NSString *nextPageToken = json[@"nextPageToken"];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate youTubeVideosDidSearch:videoIds nextPageToken:nextPageToken];
            });
        }
    }

    if ([key isEqualToString:@"videos"])
    {
        NSMutableArray *videos = @[].mutableCopy;

        for (NSDictionary *item in items)
        {
            NSMutableDictionary *video = @{}.mutableCopy;
            video[@"id"] = item[@"id"];
            video[@"title"] = item[@"snippet"][@"title"];
            video[@"author"] = item[@"snippet"][@"channelTitle"];
            video[@"length"] = [self parseISO8601Time:item[@"contentDetails"][@"duration"]].stringValue;
            video[@"thumbnail_small"] = item[@"snippet"][@"thumbnails"][@"default"][@"url"];
            video[@"thumbnail_large"] = item[@"snippet"][@"thumbnails"][@"high"][@"url"];
            video[@"length_seconds"] = [self parseISO8601Time:item[@"contentDetails"][@"duration"]].stringValue;
            video[@"source"] = [NSString stringWithFormat:@"https://youtu.be/%@", item[@"id"]];
            [videos addObject:video];
        }

        if ([self.delegate respondsToSelector:@selector(youTubeVideosDidLoad:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate youTubeVideosDidLoad:videos];
            });
        }
    }

    return YES;
}

@end
