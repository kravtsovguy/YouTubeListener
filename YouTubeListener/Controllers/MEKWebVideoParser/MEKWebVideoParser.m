//
//  MEKWebVideoParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKWebVideoParser.h"

@interface MEKWebVideoParser ()

@property (nonatomic, strong) MEKDownloadController *downloadController;

- (NSString*)generateIdForVideoItem: (VideoItemMO*) item;
- (NSURL*)generateUrlForVideoItem: (VideoItemMO*)item;
- (void)parseQueryContent: (NSString*) content forVideoItem: (VideoItemMO*) item;

@end

@implementation MEKWebVideoParser

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _downloadController = [MEKDownloadController new];
        [_downloadController configurateUrlSessionWithBackgroundMode:NO];
        _downloadController.delegate = self;
    }
    return self;
}

#pragma mark - Public

- (void)loadVideoItem:(VideoItemMO *)item
{
    if (!item)
    {
        return;
    }
    
    item.videoId = [self generateIdForVideoItem:item];
    NSURL *url = [self generateUrlForVideoItem:item];
    
    [self.downloadController downloadDataFromURL:url forKey:item.videoId withParams:@{@"item" : item}];
}

#pragma mark - Private

- (NSString*)generateIdForVideoItem: (VideoItemMO*) item
{
    
    NSString *path = item.originURL.path;
    NSString *videoId = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    return videoId;
}

- (NSURL*)generateUrlForVideoItem: (VideoItemMO*)item
{
    return item.originURL;
}

- (void)parseQueryContent: (NSString*) content forVideoItem: (VideoItemMO*) item
{
    /* Parsing... */
}

#pragma mark - Useful

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

#pragma mark - MEKDownloadControllerDelegate

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSString *content = [NSString stringWithContentsOfFile:url.path encoding:NSUTF8StringEncoding error:nil];
    
    VideoItemMO *item = params[@"item"];
    [self parseQueryContent:content forVideoItem:item];
    [item saveObject];
    
    if (self.output && [self.output respondsToSelector:@selector(webVideoParser:didLoadItem:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.output webVideoParser:self didLoadItem:item];
        });
    }
}

@end
