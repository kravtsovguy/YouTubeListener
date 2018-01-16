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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [PlaylistMO recentPlaylistName];
}

- (void)updateData
{
    self.items = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[];
}


@end
