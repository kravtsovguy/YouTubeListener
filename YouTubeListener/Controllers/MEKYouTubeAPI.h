//
//  MEKYouTubeAPI.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 19/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MEKYouTubeSearchType)
{
    MEKYouTubeSearchQuery,
    MEKYouTubeSearchRelativeVideos
};

@protocol MEKYouTubeDelegate <NSObject>

- (void)youTubeVideosDidSearch: (NSArray*) videoIds nextPageToken: (NSString*) pageToken;
- (void)youTubeVideosDidLoad: (NSArray*) videos;

@end

@interface MEKYouTubeAPI : NSObject

@property (nonatomic, weak) id<MEKYouTubeDelegate> delegate;

- (void)searchVideosForQuery: (NSString *)query searchType: (MEKYouTubeSearchType) type maxResults: (NSUInteger) results pageToken: (NSString*) pageToken;
- (void)loadDataForVideos: (NSArray*)videoIds;

@end
