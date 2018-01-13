//
//  YouTubeParser.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoItemMO+CoreDataClass.h"

typedef NS_ENUM (NSUInteger, YouTubeParserVideoQuality) {
    YouTubeParserVideoQualitySmall144  = 17,
    YouTubeParserVideoQualitySmall240  = 36,
    YouTubeParserVideoQualityMedium360 = 18,
    YouTubeParserVideoQualityHD720     = 22,
};

@protocol YouTubeParserDelegate <NSObject>

@required
-(void) infoDidLoad: (VideoItemMO*) info forVideo: (NSString*) videoId;

@end

@interface YouTubeParser : NSObject

@property (nonatomic, weak) id<YouTubeParserDelegate> delegate;

-(void) loadVideoInfo: (NSString*) videoURL;

@end
