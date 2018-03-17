//
//  MEKVideoItemTableViewController+Private.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 24/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemTableViewController.h"
#import "VideoItemMO+CoreDataClass.h"
#import "MEKVideoItemDownloadController.h"
#import "MEKVideoItemTableViewCell.h"
#import "MEKInfoView.h"
#import "MEKCombinedActionController.h"

@interface MEKVideoItemTableViewController () <MEKVideoItemActionProtocol, MEKVideoItemDownloadControllerDelegate>

@property (nonatomic, copy) NSArray<VideoItemMO*> *videoItems;
@property (nonatomic, strong) MEKInfoView *infoView;
@property (nonatomic, strong) MEKCombinedActionController *actionController;

- (MEKVideoItemTableViewCell *)p_cellForItem: (VideoItemMO *)item;
- (void)p_updateCell: (MEKVideoItemTableViewCell *)cell;
- (void)p_updateItem: (VideoItemMO *)item;
- (void)p_removeItem: (VideoItemMO *)item;

@end
