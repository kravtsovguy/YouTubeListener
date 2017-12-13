//
//  YouTubeParser.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "YouTubeParser.h"

@interface YouTubeParser()

+(NSArray*) getYouTubeVideoInfo: (NSString*)code;
+(NSArray*) filterYouTubeVideoInfo: (NSArray*)info;

@end

@implementation YouTubeParser

+(NSDictionary*) getYouTubeVideoUrls: (NSString*)videoURL
{
    NSString *code = [[videoURL componentsSeparatedByString:@"="][1] componentsSeparatedByString:@"&"][0];
    NSArray *info = [self getYouTubeVideoInfo:code];
    info = [self filterYouTubeVideoInfo:info];
    
    NSMutableDictionary *urls = [NSMutableDictionary new];
    for (NSDictionary *params in info)
    {
        if ([params[@"type"] containsString:@"video"])
        {
            NSURL *url = [NSURL URLWithString:params[@"url"]];
            if ([params[@"itag"] isEqualToString:@"22"])
                urls[@"720p"] = url;
            
            if ([params[@"itag"] isEqualToString:@"18"])
                urls[@"360p"] = url;
            
            if ([params[@"itag"] isEqualToString:@"36"])
                urls[@"240p"] = url;
            
            if ([params[@"itag"] isEqualToString:@"17"])
                urls[@"144p"] = url;
            
            //urls[params[@"quality"]] = [NSURL URLWithString:params[@"url"]];
        }
        else
        {
            urls[@"audio"] = [NSURL URLWithString:params[@"url"]];
        }
    }
    
    return urls;
}

+(NSArray*) filterYouTubeVideoInfo: (NSArray*)info
{
    NSMutableArray *filteredInfo = [NSMutableArray new];
    for (NSDictionary *params in info)
    {
        if ([params[@"type"] containsString:@"mp4"])
            [filteredInfo addObject:params];
    }
    
    return filteredInfo;
}

+(NSArray*) getYouTubeVideoInfo: (NSString*)code
{
    NSMutableArray *info = [NSMutableArray new];
    NSMutableDictionary *allInfo = [NSMutableDictionary new];
    
    NSError *error;
    NSStringEncoding encoding;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtube.com/get_video_info?video_id=%@", code]];
    NSString *content = [[NSString alloc] initWithContentsOfURL:url
                                                   usedEncoding:&encoding
                                                          error:&error];
    //NSLog(@"%@", content);
    
    //content = [content stringByRemovingPercentEncoding];
    //content = [content stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    
    allInfo[@"thumbnail_big"] = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/hqdefault.jpg", code]];
    allInfo[@"thumbnail_small"] = [NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", code]];
    
    NSArray *components = [content componentsSeparatedByString:@"&"];
    for (NSString *component in components)
    {
        if([component containsString:@"url_encoded_fmt_stream_map="]) //adaptive_fmts
        {
            content = [[component componentsSeparatedByString:@"url_encoded_fmt_stream_map="][1] stringByRemovingPercentEncoding];
        }
        if([component containsString:@"title="])
        {
            allInfo[@"title"] = [[component componentsSeparatedByString:@"title="][1] stringByRemovingPercentEncoding];
        }
        
        if([component containsString:@"author="])
        {
            allInfo[@"author"] = [[component componentsSeparatedByString:@"author="][1] stringByRemovingPercentEncoding];
        }
        
        if([component containsString:@"length_seconds="])
        {
            allInfo[@"length_seconds"] = [[component componentsSeparatedByString:@"length_seconds="][1] stringByRemovingPercentEncoding];
        }
    }
    
    components = [content componentsSeparatedByString:@","];
    
    for (NSString *component in components)
    {
        NSArray *properties = [component componentsSeparatedByString:@"&"];
        NSMutableDictionary *params = [NSMutableDictionary new];
        for (NSString *propertyObject in properties)
        {
            NSArray *property = [propertyObject componentsSeparatedByString:@"="];
            params[property[0]] = [property[1] stringByRemovingPercentEncoding];
        }
        
        [info addObject:params];
    }
    return info;
}

@end
