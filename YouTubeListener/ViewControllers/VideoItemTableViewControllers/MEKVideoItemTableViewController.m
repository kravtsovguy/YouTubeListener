//
//  MEKVideoItemTableViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemTableViewController+Private.h"
#import "MEKPlayerController.h"
#import "MEKVideoItemTableViewCell.h"
#import "UIViewController+VideoItemActions.h"
#import "AppDelegate.h"
#import "PlaylistMO+CoreDataClass.h"

static NSString * const MEKVideoItemTableViewCellID = @"MEKVideoItemTableViewCell";

@implementation MEKVideoItemTableViewController

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

#pragma mark - MEKVideoItemTableViewControllerInputProtocol

- (void)unloadItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoItemMO *item = self.videoItems[indexPath.row];
    [item removeAllDownloads];

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKVideoItemTableViewCell class] forCellReuseIdentifier:MEKVideoItemTableViewCellID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.downloadController.delegate = self;
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    MEKVideoItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MEKVideoItemTableViewCellID forIndexPath:indexPath];

    cell.delegate = self;
    VideoItemMO *item = self.videoItems[indexPath.row];

    double progress = [self.downloadController getProgressForVideoItem:item];

    if ([item hasDownloaded])
        progress = 1;

    [cell setDownloadProgress:progress];

    [cell setWithVideoItem:item];

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videoItems.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEKVideoItemTableViewCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row >= self.videoItems.count)
    {
        return;
    }
    
    VideoItemMO *item = self.videoItems[indexPath.row];
    [self.playerController openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *unloadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unload"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

        [self unloadItemAtIndexPath:indexPath];
    }];

    unloadAction.backgroundColor = [UIColor orangeColor];

    NSArray *actions = @[];

    VideoItemMO *item = self.videoItems[indexPath.row];
    if ([item hasDownloaded])
    {
        actions = @[unloadAction];
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
    [self videoItemDownloadControllerProgress: (error ? 0 : 1) forVideoItem:item];
}

#pragma mark - MEKModalPlaylistsViewControllerDelegate

- (void)modalPlaylistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist forVideoItem:(VideoItemMO *)item
{
    [self videoItemAddToPlaylist:item playlist:playlist];
}

@end
