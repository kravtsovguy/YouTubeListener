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
#import "MEKInfoView.h"

@interface MEKPlaylistViewController () <UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) PlaylistMO *playlist;
@property (nonatomic, strong) MEKInfoView *infoView;

@end

@implementation MEKPlaylistViewController

#pragma mark - init

- (instancetype)initWithPlaylist:(PlaylistMO *)playlist
{
    self = [super init];
    if (self)
    {
        _playlist = playlist;
    }

    return self;
}

#pragma mark - Properties

- (void)setVideoItems:(NSArray *)videoItems
{
    super.videoItems = videoItems;
    self.infoView.infoLabel.text = [NSString stringWithFormat:@"%@ videos", @(videoItems.count)];
}

#pragma mark - Private

- (void)loadItems
{
    [self updateData];
    [self.tableView reloadData];
}

#pragma mark - MEKVideoItemTableViewControllerInputProtocol

- (void)updateData
{
    self.videoItems = [self.playlist getVideoItems];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.playlist.name;

    self.infoView = [[MEKInfoView alloc] initWithFrame:CGRectMake(0, 0, 0, 60)];
    self.tableView.tableFooterView = self.infoView;

    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.searchBar.placeholder = @"Search by Title or Author";
    searchController.dimsBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = searchController;
    self.definesPresentationContext = YES;

    self.searchController = searchController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadItems];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.searchController.active = NO;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    self.searchController.active = NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        VideoItemMO *item = self.videoItems[indexPath.row];
        [self.actionController videoItem:item removeFromPlaylist:self.playlist];
    }];

    return @[deleteAction];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController
{
    NSString *text = searchController.searchBar.text;
    if (text.length == 0)
    {
        [self loadItems];
        return;
    }
    
    [self updateData];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@ OR author CONTAINS[c] %@", text, text];
    self.videoItems = [self.videoItems filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
    
}

#pragma mark - MEKVideoItemDelegate

- (void)videoItem:(VideoItemMO *)item removeFromPlaylist:(PlaylistMO *)playlist
{
    if (playlist != self.playlist)
    {
        return;
    }

    NSUInteger index = [self.videoItems indexOfObject:item];

    NSMutableArray *items = self.videoItems.mutableCopy;
    [items removeObjectAtIndex:index];
    self.videoItems = items;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
