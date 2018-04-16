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
#import <XCDYouTubeKit/XCDYouTubeVideoWebpage.h>
#import <XCDYouTubeKit/XCDYouTubePlayerScript.h>
#import <XCDYouTubeKit/XCDYouTubeVideo.h>
#import <XCDYouTubeKit/XCDYouTubeVideo+Private.h>

@implementation MEKYouTubeVideoParser

#pragma mark - Private

- (XCDYouTubeVideo*)videoFromHTML: (NSString*) html
{
    //Парсинг html-страницы
    XCDYouTubeVideoWebpage *webpage = [[XCDYouTubeVideoWebpage alloc] initWithHTMLString:html];

    //Загрузка скрипта для дешифрования сигнатуры (без сигнатуры невозможно получить ссылку на файл)
    NSString *script = [NSString stringWithContentsOfURL:webpage.javaScriptPlayerURL encoding:NSUTF8StringEncoding error:nil];
    XCDYouTubePlayerScript *playerScript = [[XCDYouTubePlayerScript alloc] initWithString:script];

    //Получение id видео
    NSString *videoId = webpage.videoInfo[@"vid"] ?: webpage.videoInfo[@"video_id"];

    //Получение информации о видео
    XCDYouTubeVideo *video = [[XCDYouTubeVideo alloc] initWithIdentifier:videoId info:webpage.videoInfo playerScript:playerScript response:nil error:nil];

    return video;
}

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

- (BOOL)parseQueryContent: (NSString*) content toVideoItem:(VideoItemMO **)itemRef
{
    XCDYouTubeVideo *video = [self videoFromHTML:content];

    VideoItemMO *item = *itemRef;

    item.title = video.title;
    item.author = video.author;
    item.length = video.duration;
    item.thumbnailSmall = video.smallThumbnailURL;
    item.thumbnailBig = video.largeThumbnailURL;
    item.urls = video.streamURLs;
    item.sizes = video.streamSizes;

    return YES;
}

@end
