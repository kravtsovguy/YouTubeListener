//
//  MEKRecentPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKRecentPlaylistViewController.h"
#import "MEKVideoItemTableViewController+Private.h"
#import "PlaylistMO+CoreDataClass.h"
#import "VideoItemMO+CoreDataClass.h"

@interface MEKRecentPlaylistViewController ()

@end

@implementation MEKRecentPlaylistViewController

#pragma mark - Private

- (void)deleteAllItems
{
    [self.videoItems makeObjectsPerformSelector:@selector(deleteObject)];
    self.videoItems = nil;

    NSArray<PlaylistMO*> *playlists = [PlaylistMO getPlaylistsWithContext:self.coreDataContext];
    [playlists makeObjectsPerformSelector:@selector(deleteObject)];

    NSIndexSet *indexedSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexedSet withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - MEKVideoItemTableViewControllerInputProtocol

- (void)updateData
{
    self.videoItems = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [PlaylistMO recentPlaylistName];
    
    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(p_deleteAllPressed:)];
    self.navigationItem.rightBarButtonItem = removeItem;
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[];
}

#pragma mark - MEKVideoItemDelegate

- (void)videoItemRemoveFromLibrary:(VideoItemMO *)item
{
    [self videoItem:item removeFromPlaylist:nil];
}

#pragma mark - Private

- (void)p_deleteAllPressed: (id) sender
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

@end
