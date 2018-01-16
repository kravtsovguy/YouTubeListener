//
//  YouTubeParser.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/12/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoItemMO+CoreDataClass.h"

@protocol YouTubeParserDelegate <NSObject>

@required
-(void) youtubeParserItemDidLoad: (VideoItemMO*) item;

@end

@interface YouTubeParser : NSObject

@property (nonatomic, weak) id<YouTubeParserDelegate> delegate;

-(void) loadVideoItemFromUrl: (NSURL*) url;
-(void) loadVideoItem: (VideoItemMO*) item;

@end
