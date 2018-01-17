//
//  MEKRecentPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKRecentPlaylistViewController.h"

@interface MEKRecentPlaylistViewController ()

@end

@implementation MEKRecentPlaylistViewController


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [PlaylistMO recentPlaylistName];
}

#pragma mark - Private

- (void)updateData
{
    self.items = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *actions = [super tableView:tableView editActionsForRowAtIndexPath:indexPath];
    
    if (actions.count > 1)
    {
        actions = @[actions[1]];
    }
    else
    {
        actions = @[];
    }
    
    return actions;
}


@end
