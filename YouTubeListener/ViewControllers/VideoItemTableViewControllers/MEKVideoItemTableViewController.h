//
//  MEKVideoItemTableViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEKTableViewControllerProtocol.h"
#import "MEKPropertyManagedObjectContextProtocol.h"

@interface MEKVideoItemTableViewController : UITableViewController <MEKTableViewControllerInputProtocol, MEKPropertyManagedObjectContextProtocol>

@property (nonatomic, assign, getter=isOfflineMode) BOOL offlineMode;

@end
