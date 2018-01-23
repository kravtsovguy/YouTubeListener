//
//  MEKRecentPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKRecentPlaylistViewController.h"

@interface MEKPlaylistViewController (Private) <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *items;

- (void)updateData;

@end

@interface MEKRecentPlaylistViewController ()

@end

@implementation MEKRecentPlaylistViewController


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [PlaylistMO recentPlaylistName];
    
    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllPressed:)];
    self.navigationItem.rightBarButtonItem = removeItem;
}

#pragma mark - Private

- (void)updateData
{
    self.items = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];
}

- (void)deleteAllItems
{
    [self.items makeObjectsPerformSelector:@selector(deleteObject)];
    self.items = nil;
    
    NSArray<PlaylistMO*> *playlists = [PlaylistMO getPlaylistsWithContext:self.coreDataContext];
    [playlists makeObjectsPerformSelector:@selector(deleteObject)];
    
    NSIndexSet *indexedSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexedSet withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showDeleteItemDialogAtIndexPath: (NSIndexPath *) indexPath
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Delete the video from ALL playlists?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self deleteItemAtIndexPath:indexPath];
        
    }];
    
    UIAlertAction *cancedlAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:deleteAction];
    [alert addAction:cancedlAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoItemMO *item = self.items[indexPath.row];
    
    NSArray *playlists = [PlaylistMO getPlaylistsWithContext:self.coreDataContext];
    [playlists makeObjectsPerformSelector:@selector(deleteVideoItem:) withObject:item];
    
    NSMutableArray *items = self.items.mutableCopy;
    [items removeObject:item];
    self.items = items;
    
    [item deleteObject];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Selectors

- (void)deleteAllPressed: (id) sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete all videos and playlists?"
                                                                   message:@"You will remove all data"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self deleteAllItems];
    }];
    
    UIAlertAction *cancedlAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:deleteAction];
    [alert addAction:cancedlAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *actions = [super tableView:tableView editActionsForRowAtIndexPath:indexPath];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self showDeleteItemDialogAtIndexPath:indexPath];
    }];
    
    if (actions.count > 1)
    {
        actions = @[deleteAction, actions[1]];
    }
    else
    {
        actions = @[deleteAction];
    }
    
    return actions;
}


@end
