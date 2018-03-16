//
//  MEKVideoItemTableViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemTableViewController+Private.h"
#import "MEKPlaylistTableViewCell.h"

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

- (NSManagedObjectContext*) coreDataContext
{
    return self.actionController.coreDataContext;
}

- (void)setVideoItems:(NSArray *)videoItems
{
    if (self.offlineMode)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hasDownloaded = YES"];
        videoItems = [videoItems filteredArrayUsingPredicate:predicate];
    }

    self.infoView.infoLabel.text = [NSString stringWithFormat:@"%@ videos", @(videoItems.count)];
    _videoItems = [videoItems copy];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    self.infoView = [[MEKInfoView alloc] initWithFrame:CGRectMake(0, 0, 0, 60)];
    self.tableView.tableFooterView = self.infoView;
    [self.tableView registerClass:[MEKVideoItemTableViewCell class] forCellReuseIdentifier:NSStringFromClass([MEKVideoItemTableViewCell class])];

    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(p_handleLongPress:)];
    gesture.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:gesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.actionController.downloadController.delegate = self;
}

#pragma mark - MEKVideoItemTableViewControllerInputProtocol

- (void)updateData
{
    self.videoItems = @[];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    MEKVideoItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MEKVideoItemTableViewCell class])];

    cell.delegate = self.actionController;
    VideoItemMO *item = self.videoItems[indexPath.row];

    double progress = [item hasDownloaded] ? 1 : [self.actionController.downloadController progressForVideoItem:item];
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
    [self.actionController videoItemPlay:item];
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
    if (self.offlineMode)
    {
        [self p_removeItem:item];
        return;
    }

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

- (void)p_removeItem:(VideoItemMO *)item
{
    NSMutableArray *items = self.videoItems.mutableCopy;
    [items removeObject:item];
    self.videoItems = items;

    UITableViewCell *cell = [self p_cellForItem:item];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (MEKVideoItemTableViewCell *)p_cellForItem: (VideoItemMO *)item
{
    __block MEKVideoItemTableViewCell *cell;

    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[MEKVideoItemTableViewCell class]])
        {
            return;
        }

        cell = obj;

        if (cell.item.videoId != item.videoId)
        {
            cell = nil;
            return;
        }

        *stop = YES;
    }];

    return cell;
}

- (void)p_updateCell: (MEKVideoItemTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)p_updateItem: (VideoItemMO *)item
{
    MEKVideoItemTableViewCell *cell = [self p_cellForItem:item];
    [self p_updateCell:cell];
}

- (void)p_handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
    {
        return;
    }

    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (!indexPath)
    {
        return;
    }

    MEKVideoItemTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[MEKVideoItemTableViewCell class]])
    {
        return;
    }

    VideoItemMO *item = cell.item;
    [self.actionController videoItemShowActions:item];
}

@end
