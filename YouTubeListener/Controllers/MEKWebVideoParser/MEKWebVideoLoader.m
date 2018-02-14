//
//  MEKWebVideoParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKWebVideoLoader.h"
#import "MEKWebDownloadController.h"
#import "MEKDownloadController.h"
#import "MEKYouTubeVideoParser.h"

@interface MEKWebVideoLoader () <MEKDownloadControllerDelegate, MEKWebDownloadControllerDelegate>

@property (nonatomic, strong) MEKDownloadController *downloadController;
@property (nonatomic, strong) MEKWebDownloadController *webDownloadController;

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

        _webDownloadController = [MEKWebDownloadController new];
        _webDownloadController.delegate = self;
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
    
    item.videoId = [parser generateIdForVideoItem:item];
    NSURLRequest *request = [parser generateRequestForVideoItem:item];
    NSDictionary *params = @{@"item" : item, @"parser" : parser};

    id <MEKDownloadControllerInputProtocol> downloadController = [parser shouldUseWebBrowser] ? self.webDownloadController :  self.downloadController;
    [downloadController downloadDataFromRequest:request forKey:item.videoId withParams:params];

    return YES;
}

#pragma mark - MEKDownloadControllerOutputProtocol

- (BOOL)downloadControllerDidFinish:(id<MEKDownloadControllerInputProtocol>)downloadController withTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSString *content = [NSString stringWithContentsOfFile:url.path encoding:NSUTF8StringEncoding error:nil];
    
    VideoItemMO *item = params[@"item"];
    id<MEKWebVideoParserProtocol> parser = params[@"parser"];
    
    BOOL isParsed = [parser parseQueryContent:content toVideoItem:&item];

    if (isParsed)
    {
        [item saveObject];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.output webVideoLoader:self didLoadItem:item];
        });
    }

    return isParsed;
}

@end
