//
//  MEKDownloadsPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDownloadsPlaylistViewController.h"
#import "MEKVideoItemTableViewController+Private.h"
#import "PlaylistMO+CoreDataClass.h"
#import "VideoItemMO+CoreDataClass.h"

@interface MEKDownloadsPlaylistViewController ()

@end

@implementation MEKDownloadsPlaylistViewController

#pragma mark - Private

- (void)unloadAllItems
{
    [self.videoItems makeObjectsPerformSelector:@selector(removeAllDownloads)];
    self.videoItems = nil;

    NSIndexSet *indexedSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexedSet withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - MEKVideoItemTableViewControllerInputProtocol

- (void)updateData
{
    NSArray *items = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hasDownloaded == YES"];
    items = [items filteredArrayUsingPredicate:predicate];

    self.videoItems = items;
}

- (void)unloadItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoItemMO *item = self.videoItems[indexPath.row];
    [item removeAllDownloads];

    NSMutableArray *items = self.videoItems.mutableCopy;
    [items removeObject:item];
    self.videoItems = items;

    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [PlaylistMO downloadsPlaylistName];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllPressed:)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *unloadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unload"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

        [self unloadItemAtIndexPath:indexPath];
    }];

    unloadAction.backgroundColor = [UIColor orangeColor];
    
    return @[unloadAction];
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

@end
