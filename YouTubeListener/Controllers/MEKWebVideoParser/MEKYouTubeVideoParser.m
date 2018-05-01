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
#import "VideoItemMO+CoreDataClass.h"
#import <XCDYouTubeKit/XCDYouTubeClient.h>

@implementation MEKYouTubeVideoParser

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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://youtu.be/%@", item.videoId]];
    return url;
}

- (BOOL)parseQueryContent: (NSString*) content toVideoItem:(VideoItemMO *)item
{
    __block XCDYouTubeVideo *video;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [[XCDYouTubeClient defaultClient]
     getVideoWithIdentifier:item.videoId
     completionHandler:^(XCDYouTubeVideo * _Nullable tempVideo, NSError * _Nullable error) {
         video = tempVideo;
         dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    item.title = video.title;
    item.author = video.author;
    item.length = video.duration;
    item.thumbnailSmall = video.smallThumbnailURL;
    item.thumbnailBig = video.largeThumbnailURL;
    item.urls = video.streamURLs;
    item.sizes = video.streamSizes;

    return YES;
}

- (MEKLoadType)loadType
{
    return MEKLoadNone;
}

@end
