//
//  MEKVideoItemTableViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEKPropertyManagedObjectContextProtocol.h"
#import "MEKPropertyDownloadControllerProtocol.h"
#import "MEKPropertyPlayerControllerProtocol.h"

@protocol MEKVideoItemTableViewControllerInputProtocol

@optional
- (void)updateData;

@end

@interface MEKVideoItemTableViewController : UITableViewController <MEKVideoItemTableViewControllerInputProtocol, MEKPropertyManagedObjectContextProtocol, MEKPropertyDownloadControllerProtocol, MEKPropertyPlayerControllerProtocol>

@end
