//
//  MEKSearchResultsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 22/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEKYouTubeAPI;
@class MEKPlayerController;

@interface MEKSearchResultsViewController : UIViewController

@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;
@property (nonatomic, readonly) MEKPlayerController *playerController;
@property (nonatomic, readonly) MEKYouTubeAPI *youtubeAPI;
@property (nonatomic, copy, readonly) NSString *query;

- (instancetype)initWithAPI: (MEKYouTubeAPI*) youtubeAPI andQuery: (NSString*) query;

@end
