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
#import "MEKModalPlaylistsViewController.h"
#import "MEKWebVideoLoader.h"

@interface MEKVideoItemTableViewController () <MEKVideoItemDelegate, MEKVideoItemDownloadControllerDelegate, MEKModalPlaylistsViewControllerDelegate, MEKWebVideoLoaderOutputProtocol, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray<VideoItemMO*> *videoItems;
@property (nonatomic, strong) MEKWebVideoLoader *loader;

@end
