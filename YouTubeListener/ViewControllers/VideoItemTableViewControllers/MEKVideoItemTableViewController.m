//
//  MEKVideoItemTableViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemTableViewController+Private.h"
#import "MEKPlayerController.h"
#import "AppDelegate.h"

static NSString * const MEKVideoItemTableViewCellID = @"MEKVideoItemTableViewCell";

@implementation MEKVideoItemTableViewController

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _actionController = [[MEKVideoItemActionController alloc] init];
        _actionController.delegate = self;
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
    return self.actionController.downloadController;
}

- (NSManagedObjectContext*) coreDataContext
{
    return self.actionController.coreDataContext;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKVideoItemTableViewCell class] forCellReuseIdentifier:MEKVideoItemTableViewCellID];

    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(p_handleLongPress:)];
    gesture.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:gesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.downloadController.delegate = self;
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    MEKVideoItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MEKVideoItemTableViewCellID forIndexPath:indexPath];

    cell.delegate = self.actionController;
    VideoItemMO *item = self.videoItems[indexPath.row];

    double progress = [item hasDownloaded] ? 1 : [self.downloadController progressForVideoItem:item];
    [cell setDownloadProgress:progress];

    BOOL isAdded = [item addedToLibrary:self.coreDataContext];
    [cell setWithVideoItem:item addedToLibrary:isAdded];

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

#pragma mark - MEKVideoItemDelegate

- (void)videoItemAddToLibrary:(VideoItemMO *)item
{
    [self p_updateItem:item];
}

- (void)videoItemRemoveFromLibrary:(VideoItemMO *)item
{
    [self p_updateItem:item];
}

- (void)videoItemRemoveDownload:(VideoItemMO *)item
{
    [self p_updateItem:item];
}

#pragma mark - MEKVideoItemDownloadControllerDelegate

- (void)videoItemDownloadControllerProgress:(double)progress forVideoItem:(VideoItemMO *)item
{
    MEKVideoItemTableViewCell *cell = [self p_cellForItem:item];

    if (progress == 1)
    {
        [self p_updateCell:cell];
    }
    else
    {
        [cell setDownloadProgress:progress];
    }
}

- (void)videoItemDownloadControllerDidFinishWithError:(NSError *)error forVideoItem:(VideoItemMO *)item
{
    [self videoItemDownloadControllerProgress: (error ? 0 : 1) forVideoItem:item];
}

#pragma mark - Private

- (MEKVideoItemTableViewCell *)p_cellForItem: (VideoItemMO *)item
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item.videoId = %@", item.videoId];
    MEKVideoItemTableViewCell *cell = [self.tableView.visibleCells filteredArrayUsingPredicate:predicate].firstObject;
    return cell;
}

- (void)p_updateCell: (MEKVideoItemTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)p_updateItem: (VideoItemMO *)item
{
    MEKVideoItemTableViewCell *cell = [self p_cellForItem:item];
    [self p_updateCell:cell];
}

- (void)p_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (!indexPath)
    {
        return;
    }

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        VideoItemMO *item = self.videoItems[indexPath.row];
        [self.actionController videoItemShowActions:item];
    }
}

@end
