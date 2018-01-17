//
//  MEKDownloadsPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDownloadsPlaylistViewController.h"

@interface MEKDownloadsPlaylistViewController ()

@end

@implementation MEKDownloadsPlaylistViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [PlaylistMO downloadsPlaylistName];
}

#pragma mark - Private

- (void)updateData
{
    NSArray *items = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hasDownloaded == YES"];
    items = [items filteredArrayUsingPredicate:predicate];
    
    self.items = items;
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *unloadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Unload"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        VideoItemMO *item = self.items[indexPath.row];
        [item removeDownloadAll];
        
        NSMutableArray *items = self.items.mutableCopy;
        [items removeObjectAtIndex:indexPath.row];
        self.items = items;
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    unloadAction.backgroundColor = UIColor.orangeColor;
    
    return @[unloadAction];
}

@end
