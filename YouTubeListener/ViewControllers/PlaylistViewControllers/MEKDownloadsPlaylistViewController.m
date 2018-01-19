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
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllPressed:)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - Private

- (void)updateData
{
    NSArray *items = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hasDownloaded == YES"];
    items = [items filteredArrayUsingPredicate:predicate];
    
    self.items = items;
}

#pragma mark - Selectors

- (void)deleteAllPressed: (id) sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete all saved videos?"
                                                                   message:@"You will remove all downloads"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.items makeObjectsPerformSelector:@selector(removeAllDownloads)];
        self.items = nil;
        
        NSIndexSet *indexedSet = [NSIndexSet indexSetWithIndex:0];
        [self.tableView reloadSections:indexedSet withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    UIAlertAction *cancedlAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:deleteAction];
    [alert addAction:cancedlAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *unloadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Unload"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        VideoItemMO *item = self.items[indexPath.row];
        [item removeAllDownloads];
        
        NSMutableArray *items = self.items.mutableCopy;
        [items removeObjectAtIndex:indexPath.row];
        self.items = items;
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    unloadAction.backgroundColor = UIColor.orangeColor;
    
    return @[unloadAction];
}

@end
