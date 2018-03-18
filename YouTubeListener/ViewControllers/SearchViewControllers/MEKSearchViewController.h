//
//  MEKSearchViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 21/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEKSearchViewController;

@protocol MEKSearchViewControllerDelegate <NSObject>

@optional
- (void)searchViewControllerDidUpdateQueries: (MEKSearchViewController*) searchViewController;
- (void)searchViewController: (MEKSearchViewController*) searchViewController didAddQuery: (NSString *) query;
- (void)searchViewController: (MEKSearchViewController*) searchViewController didRemoveQuery: (NSString *) query;

@end

@interface MEKSearchViewController : UITableViewController

@property (nonatomic, weak) id <MEKSearchViewControllerDelegate> delegate;
@property (nonatomic, copy, readonly) NSArray<NSString*> *queries;

- (instancetype)initWithQueries: (NSArray<NSString*>*) queries;

@end
