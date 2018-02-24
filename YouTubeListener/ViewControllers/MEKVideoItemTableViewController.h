//
//  MEKVideoItemTableViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoItemMO;
@class MEKPlayerController;
@class MEKVideoItemDownloadController;

@protocol MEKVideoItemTableViewControllerInputProtocol

@optional
- (void)updateData;
- (void)unloadItemAtIndexPath: (NSIndexPath *) indexPath;
- (void)removeItemAtIndexPath: (NSIndexPath *) indexPath;

@end

@interface MEKVideoItemTableViewController : UITableViewController <MEKVideoItemTableViewControllerInputProtocol>

@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;
@property (nonatomic, readonly) MEKPlayerController *playerController;
@property (nonatomic, readonly) MEKVideoItemDownloadController *downloadController;

@end
