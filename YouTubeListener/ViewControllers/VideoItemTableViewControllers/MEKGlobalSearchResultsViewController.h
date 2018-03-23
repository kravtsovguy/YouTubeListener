//
//  MEKGlobalSearchResultsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 22/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKResultsViewController.h"

@class MEKYouTubeAPI;

@interface MEKGlobalSearchResultsViewController : MEKResultsViewController

@property (nonatomic, strong) MEKYouTubeAPI *youtubeAPI;

@end
