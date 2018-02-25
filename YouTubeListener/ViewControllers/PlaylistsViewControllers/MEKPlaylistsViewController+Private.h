//
//  MEKPlaylistsViewController+Private.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 25/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistsViewController.h"
#import "MEKPlaylistTableViewCell.h"
#import "PlaylistMO+CoreDataClass.h"

@interface MEKPlaylistsViewController () <UIViewControllerPreviewingDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<PlaylistMO*> *playlists;
@property (nonatomic, strong) MEKPlaylistTableViewCell *headerCell;
@property (nonatomic, strong) id<UIViewControllerPreviewing> previewingContext;

@end
