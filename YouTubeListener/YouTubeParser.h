//
//  YouTubeParser.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YouTubeParserDelegate <NSObject>

-(void) videoInfoDidLoad: (NSDictionary*) info forVideoId: (NSString*) videoId;

@end

@interface YouTubeParser : NSObject

+(NSDictionary*) getYouTubeVideoUrls: (NSString*)videoURL;

@property (nonatomic, weak) id<YouTubeParserDelegate> delegate;

@end
