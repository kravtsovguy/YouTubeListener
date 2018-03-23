//
//  MEKCombinedSearchResultsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 19/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEKResultsViewController;

typedef NS_ENUM(NSUInteger, MEKResultsType)
{
    MEKResultsNone = 0,
    MEKResultsLocal,
    MEKResultsGlobal
};

@interface MEKCombinedSearchResultsViewController : UIViewController

@property (nonatomic, copy) NSString *query;

@property (nonatomic, strong, readonly) MEKResultsViewController *localResultsViewController;
@property (nonatomic, strong, readonly) MEKResultsViewController *globalResultsViewController;

@property (nonatomic, assign) MEKResultsType currentType;

@end
