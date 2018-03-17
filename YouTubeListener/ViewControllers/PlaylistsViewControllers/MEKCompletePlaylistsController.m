//
//  MEKCompletePlaylistsController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCompletePlaylistsController.h"
#import "MEKPlaylistsViewController+Private.h"
#import "MEKPlaylistActionController+Alerts.h"

@implementation MEKCompletePlaylistsController

#pragma mark MEKTableViewControllerInputProtocol

- (void)updateData
{
    self.playlists = [PlaylistMO getPlaylistsWithContext:self.coreDataContext];
}

#pragma mark - UIViewController

- (NSString *)title
{
    return @"Playlists";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(p_createPlaylistPressed:)];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateData];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistMO *playlist = self.playlists[indexPath.row];

    UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self.actionController.playlistActionController showRenamePlaylistDialog:playlist];
    }];
    renameAction.backgroundColor = [UIColor lightGrayColor];

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self.actionController.playlistActionController showRemovePlaylistDialog:playlist];
    }];

    return @[deleteAction, renameAction];
}

#pragma mark - Private

- (void)p_createPlaylistPressed: (id) sender
{
    [self.actionController.playlistActionController showCreatePlaylistDialog];
}

@end
