//
//  YouTubeParser.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, RMYouTubeExtractorVideoQuality) {
    YouTubeParserVideoQualitySmall240  = 36,
    YouTubeParserVideoQualityMedium360 = 18,
    YouTubeParserVideoQualityHD720     = 22,
};

@protocol YouTubeParserDelegate <NSObject>

@required
-(void) infoDidLoad: (NSDictionary*) info forVideo: (NSString*) videoId;

@end

@interface YouTubeParser : NSObject

@property (nonatomic, weak) id<YouTubeParserDelegate> delegate;

-(void) loadVideoInfo: (NSString*) videoURL;

@end
