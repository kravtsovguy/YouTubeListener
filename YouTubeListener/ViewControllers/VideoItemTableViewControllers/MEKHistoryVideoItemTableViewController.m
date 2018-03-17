//
//  MEKHistoryVideoItemTableViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKHistoryVideoItemTableViewController.h"
#import "MEKVideoItemTableViewController+Private.h"
#import "MEKVideoItemActionController.h"

@interface MEKHistoryVideoItemTableViewController ()

@end

@implementation MEKHistoryVideoItemTableViewController

#pragma mark - init

- (instancetype)init
{
    return [self initWithUserDefaults:nil];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self)
    {
        _userDefaults = userDefaults ?: self.actionController.videoItemActionController.userDefaults;
    }
    return self;
}

#pragma mark - UIViewController

- (NSString *)title
{
    return @"History";
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
    self.videoItems = [VideoItemMO historyVideoItemsFromUserDefaults:self.userDefaults withContext:self.coreDataContext] ?: @[];
}

#pragma mark - MEKVideoItemActionProtocol

- (void)videoItemRemoveFromLibrary:(VideoItemMO *)item
{
    [self updateData];
    [self.tableView reloadData];
}

@end
