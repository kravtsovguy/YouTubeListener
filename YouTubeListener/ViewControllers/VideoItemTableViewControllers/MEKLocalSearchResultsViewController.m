//
//  MEKLocalSearchResultsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 18/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKLocalSearchResultsViewController.h"
#import "MEKVideoItemTableViewController+Private.h"
#import "VideoItemMO+CoreDataClass.h"

@interface MEKLocalSearchResultsViewController ()

@end

@implementation MEKLocalSearchResultsViewController

- (void)setQuery:(NSString *)query
{
    super.query = query;
    
    [self updateData];
    [self.tableView reloadData];
}

#pragma mark - MEKTableViewControllerInputProtocol

- (void)updateData
{
    if (!self.query)
    {
        [super updateData];
        return;
    }

    NSFetchRequest *fetchRequest = [VideoItemMO fetchRequest];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@ OR author CONTAINS[c] %@", self.query, self.query];
    fetchRequest.predicate = predicate;

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];

    self.videoItems = [VideoItemMO executeFetchRequest:fetchRequest withContext:self.coreDataContext];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateData];
    [self.tableView reloadData];
}

@end
