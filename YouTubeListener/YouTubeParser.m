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

@property (nonatomic, strong) NSString *currentVideoId;
@property (nonatomic, strong) MEKDownloadController *downloadController;
@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;

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

- (NSManagedObjectContext*)coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    NSPersistentContainer *container = ((AppDelegate*)(application.delegate)).persistentContainer;
    
    NSManagedObjectContext *context = container.viewContext;
    
    return context;
}

- (void)loadVideoItem:(VideoItemMO *)item
{
    NSURL *youtubeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://youtu.be/%@", item.videoId]];
    [self loadVideoItemFromUrl:youtubeUrl];
}

- (void)loadVideoItemFromUrl:(NSURL *)url
{
    NSString *videoURL = url.absoluteString;
    NSString *code;
    
    if ([videoURL containsString:@"youtube"])
        code = [[videoURL componentsSeparatedByString:@"="][1] componentsSeparatedByString:@"&"][0];
    else
        code = [videoURL componentsSeparatedByString:@"youtu.be/"][1];
    
    self.currentVideoId = code;
    
    NSURL *infoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtube.com/get_video_info?video_id=%@&hl=ru_RU", code]];
    
    [self.downloadController downloadDataFromURL:infoUrl forKey:code];
}

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key
{
    NSString *content = [NSString stringWithContentsOfFile:url.path encoding:NSUTF8StringEncoding error:nil];
    VideoItemMO *item = [self parseQueryContent:content];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(youtubeParserItemDidLoad:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate youtubeParserItemDidLoad:item];
        });
    }
}

- (VideoItemMO*) parseQueryContent: (NSString*) content
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
    
    VideoItemMO *item = [VideoItemMO getVideoItemForId:self.currentVideoId withContext:self.coreDataContext];
    if (!item)
    {
        item = [VideoItemMO getEmptyWithContext:self.coreDataContext];
        item.videoId = self.currentVideoId;
        item.title = info[@"title"];
        item.author = info[@"author"];
        item.length = ((NSString*)info[@"length_seconds"]).doubleValue;
        item.thumbnailSmall = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", item.videoId]];
        item.thumbnailBig = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", item.videoId]];

    }
    
    item.urls = result[@"urls"];
    item.added = [NSDate new];
    
    return item;
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
