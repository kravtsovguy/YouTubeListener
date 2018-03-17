//
//  MEKPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistViewController.h"
#import "MEKVideoItemTableViewController+Private.h"
#import "PlaylistMO+CoreDataClass.h"
#import "MEKPlaylistActionController.h"

@interface MEKPlaylistViewController ()

@property (nonatomic, strong) PlaylistMO *playlist;

@end

@implementation MEKPlaylistViewController

#pragma mark - init

- (instancetype)initWithPlaylist:(PlaylistMO *)playlist
{
    self = [super init];
    if (self)
    {
        _playlist = playlist;
        super.actionController.playlistActionController.delegate = self;
    }

    return self;
}

#pragma mark - MEKTableViewControllerInputProtocol

- (void)updateData
{
    self.videoItems = [self.playlist getVideoItems];
}

#pragma mark - UIViewController

- (NSString *)title
{
    return self.playlist.name;
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
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        VideoItemMO *item = self.videoItems[indexPath.row];
        [self.actionController.playlistActionController playlist:self.playlist removeVideoItem:item];
    }];

    return @[deleteAction];
}

#pragma mark - MEKPlaylistActionProtocol

- (void)playlist:(PlaylistMO *)playlist removeVideoItem:(VideoItemMO *)item
{
    if (playlist != self.playlist)
    {
        return;
    }

    [self p_removeItem:item];
}

@end
