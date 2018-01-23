//
//  MEKDownloadsPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDownloadsPlaylistViewController.h"

@interface MEKPlaylistViewController (Private) <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *items;

- (void)updateData;
- (void)unloadItemAtIndexPath: (NSIndexPath *) indexPath;

@end

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

- (void)unloadItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoItemMO *item = self.items[indexPath.row];
    [item removeAllDownloads];
    
    NSMutableArray *items = self.items.mutableCopy;
    [items removeObject:item];
    self.items = items;
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)unloadAllItems
{
    [self.items makeObjectsPerformSelector:@selector(removeAllDownloads)];
    self.items = nil;
    
    NSIndexSet *indexedSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexedSet withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Selectors

- (void)deleteAllPressed: (id) sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unload all saved videos?"
                                                                   message:@"You will remove all downloads"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Unload All" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self unloadAllItems];
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
    return @[actions[1]];
}

@end
