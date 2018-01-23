//
//  MEKPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistViewController.h"
#import "VideoItemMO+CoreDataClass.h"
#import <Masonry/Masonry.h>
#import "MEKVideoItemTableViewCell.h"
#import "MEKModalPlaylistsViewController.h"
#import "MEKWebVideoLoader.h"
#import "MEKInfoView.h"
#import "AppDelegate.h"

static NSString *MEKVideoItemTableViewCellID = @"MEKVideoItemTableViewCell";

@interface MEKPlaylistViewController () <MEKVideoItemDelegate, MEKVideoItemDownloadControllerDelegate, MEKWebVideoLoaderOutputProtocol, MEKModalPlaylistsViewControllerDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) MEKWebVideoLoader *loader;
@property (nonatomic, strong) PlaylistMO *playlist;
@property (nonatomic, strong) MEKInfoView *infoView;

- (void)updateData;
- (void)loadItems;
- (void)unloadItemAtIndexPath: (NSIndexPath *) indexPath;
- (void)removeItemFromPlaylistAtIndexPath: (NSIndexPath *) indexPath;

@end

@implementation MEKPlaylistViewController

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _loader = [MEKWebVideoLoader new];
        _loader.output = self;
    }
    return self;
}

- (instancetype)initWithPlaylist:(PlaylistMO *)playlist
{
    self = [self init];
    if (self)
    {
        _playlist = playlist;
    }
    
    return self;
}

#pragma mark - Properties

- (MEKPlayerController *)playerController
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;
    
    return appDelegate.playerController;
}

- (MEKVideoItemDownloadController *)downloadController
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;
    
    return appDelegate.downloadController;
}

- (NSManagedObjectContext*) coreDataContext
{
    return self.playerController.coreDataContext;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    self.infoView.infoLabel.text = [NSString stringWithFormat:@"%@ videos", @(items.count)];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.playlist.name;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKVideoItemTableViewCell class] forCellReuseIdentifier:MEKVideoItemTableViewCellID];
    
    self.infoView = [[MEKInfoView alloc] initWithFrame:CGRectMake(0, 0, 0, MEKPlayerViewHeightSizeMinimized)];
    self.tableView.tableFooterView = self.infoView;
    
    [self.view addSubview:self.tableView];
    
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.searchBar.placeholder = @"Search by Title or Author";
    searchController.dimsBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = searchController;
    self.definesPresentationContext = YES;
    
    self.searchController = searchController;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.downloadController.delegate = self;
    [self loadItems];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.searchController.active = NO;
}

#pragma mark - Private

- (void)updateData
{
    self.items = [self.playlist getVideoItems];
}

- (void)loadItems
{
    [self updateData];
    [self.tableView reloadData];
}

- (void)unloadItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoItemMO *item = self.items[indexPath.row];
    [item removeAllDownloads];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeItemFromPlaylistAtIndexPath: (NSIndexPath *) indexPath
{
    VideoItemMO *item = self.items[indexPath.row];
    [self.playlist deleteVideoItem:item];
    
    NSMutableArray *items = self.items.mutableCopy;
    [items removeObjectAtIndex:indexPath.row];
    self.items = items;
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MEKVideoItemTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MEKVideoItemTableViewCellID forIndexPath:indexPath];
    
    cell.delegate = self;
    VideoItemMO *item = self.items[indexPath.row];
    
    double progress = [self.downloadController getProgressForVideoItem:item];
    
    if ([item hasDownloaded])
        progress = 1;
    
    [cell setDownloadProgress:progress];
    
    [cell setWithVideoItem:item];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEKVideoItemTableViewCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    VideoItemMO *item = self.items[indexPath.row];
    [self.playerController openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];
    
    self.searchController.active = NO;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *unloadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unload"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self unloadItemAtIndexPath:indexPath];
    }];
    
    unloadAction.backgroundColor = [UIColor orangeColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self removeItemFromPlaylistAtIndexPath:indexPath];
    }];
    
    NSArray *actions = @[deleteAction];

    VideoItemMO *item = self.items[indexPath.row];
    if ([item hasDownloaded])
    {
        actions = @[deleteAction, unloadAction];
    }
    
    return actions;
}

#pragma mark - MEKVideoItemDelegate

- (void)videoItemAddToPlaylist:(VideoItemMO *)item
{
    [self vi_choosePlaylistForVideoItem:item];
}

- (void)videoItemAddToPlaylist:(VideoItemMO *)item playlist:(PlaylistMO *)playlist
{
    [playlist addVideoItem:item];
}

- (void)videoItemDownload: (VideoItemMO*) item
{
    if (item.urls)
    {
        [self vi_showDownloadingDialogForVideoItem:item handler:^(VideoItemQuality quality) {
            [self videoItemDownload:item withQuality:quality];
        }];
    }
    else
    {
        [self.loader loadVideoItem:item];
    }
}

- (void)videoItemDownload:(VideoItemMO *)item withQuality:(VideoItemQuality)quality
{
    [self.downloadController downloadVideoItem:item withQuality:quality];
}

- (void)videoItemCancelDownload:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadingVideoItem:item];
}

#pragma mark - MEKWebVideoLoaderOutputProtocol

- (void)webVideoLoader:(id<MEKWebVideoLoaderInputProtocol>)loader didLoadItem:(VideoItemMO *)item
{
    [self videoItemDownload:item];
}

#pragma mark - MEKVideoItemDownloadControllerDelegate

- (void)videoItemDownloadControllerProgress:(double)progress forVideoItem:(VideoItemMO *)item
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item.videoId = %@", item.videoId];
    MEKVideoItemTableViewCell *cell = [self.tableView.visibleCells filteredArrayUsingPredicate:predicate].firstObject;
    
    [cell setDownloadProgress:progress];

    if (progress == 1)
    {
        [cell setWithVideoItem:item];
    }
}

- (void)videoItemDownloadControllerDidFinishWithError:(NSError *)error forVideoItem:(VideoItemMO *)item
{
    if (error)
    {
        [self videoItemDownloadControllerProgress:0 forVideoItem:item];
    }
    else
    {
        [self videoItemDownloadControllerProgress:1 forVideoItem:item];
    }
}

#pragma mark - MEKModalPlaylistsViewControllerDelegate

- (void)modalPlaylistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist forVideoItem:(VideoItemMO *)item
{
    [self videoItemAddToPlaylist:item playlist:playlist];
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
    self.items = [self.items filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
    
}

@end
