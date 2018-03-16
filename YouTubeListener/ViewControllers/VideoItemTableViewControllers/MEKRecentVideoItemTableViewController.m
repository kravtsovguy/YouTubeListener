//
//  MEKRecentVideoItemTableViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKRecentVideoItemTableViewController.h"
#import "MEKVideoItemTableViewController+Private.h"

@interface MEKRecentVideoItemTableViewController ()

@end

@implementation MEKRecentVideoItemTableViewController

#pragma mark - UIViewController

- (NSString *)title
{
    return @"Recently Added";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateData];
    [self.tableView reloadData];
}

#pragma mark - MEKVideoItemTableViewControllerInputProtocol

- (void)updateData
{
    self.videoItems = [VideoItemMO addedVideoItemsWithContext:self.coreDataContext];
}

#pragma mark - MEKVideoItemDelegate

- (void)videoItemRemoveFromLibrary:(VideoItemMO *)item
{
    [self p_removeItem:item];
}

@end
