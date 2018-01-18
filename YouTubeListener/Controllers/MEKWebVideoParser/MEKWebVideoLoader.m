//
//  MEKWebVideoParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKWebVideoLoader.h"
#import "MEKDownloadController.h"
#import "MEKYouTubeVideoParser.h"

@interface MEKWebVideoLoader () <MEKDownloadControllerDelegate>

@property (nonatomic, strong) MEKDownloadController *downloadController;

@end

@implementation MEKWebVideoLoader

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

#pragma mark - Public Static

+ (id<MEKWebVideoParserProtocol>)parserForURL:(NSURL *)url
{
    NSString *urlString = url.absoluteString;
    
    id<MEKWebVideoParserProtocol> parser;
    
    if ([urlString containsString:@"youtu"])
    {
        parser = [MEKYouTubeVideoParser new];
    }
    
    return parser;
}

#pragma mark - Public

- (BOOL)loadVideoItem:(VideoItemMO *)item
{
    if (!item)
    {
        return NO;
    }
    
    id <MEKWebVideoParserProtocol> parser = [MEKWebVideoLoader parserForURL:item.originURL];
    
    if (!parser)
    {
        return NO;
    }
    
    item.videoId = [self generateIdForVideoItem:item];
    
    if ([parser respondsToSelector:@selector(generateIdForVideoItem:)])
    {
        item.videoId = [parser generateIdForVideoItem:item];
    }
    
    NSURL *url = [self generateUrlForVideoItem:item];
    
    if ([parser respondsToSelector:@selector(generateUrlForVideoItem:)])
    {
        url = [parser generateUrlForVideoItem:item];
    }
    
    NSDictionary *params = @{@"item" : item, @"parser" : parser};
    [self.downloadController downloadDataFromURL:url forKey:item.videoId withParams:params];
    
    return YES;
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

#pragma mark - MEKDownloadControllerDelegate

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSString *content = [NSString stringWithContentsOfFile:url.path encoding:NSUTF8StringEncoding error:nil];
    
    VideoItemMO *item = params[@"item"];
    id<MEKWebVideoParserProtocol> parser = params[@"parser"];
    
    [parser parseQueryContent:content toVideoItem:item];
    [item saveObject];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.output webVideoLoader:self didLoadItem:item];
    });
}

@end
