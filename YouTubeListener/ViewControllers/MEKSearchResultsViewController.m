//
//  MEKSearchResultsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 22/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKSearchResultsViewController.h"
#import <Masonry/Masonry.h>
#import "MEKYouTubeAPI.h"
#import "AppDelegate.h"
#import "VideoItemMO+CoreDataClass.h"
#import "MEKPlayerViewController.h"
#import "MEKLoaderTableViewCell.h"
#import "MEKVideoItemTableViewCell.h"

static NSString * const MEKVideoItemTableViewCellID = @"MEKVideoItemTableViewCell";
static NSString * const MEKLoaderTableViewCellID = @"MEKLoaderTableViewCell";
static NSUInteger const MEKResultsCount = 10;

@interface MEKSearchResultsViewController () <MEKYouTubeDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MEKYouTubeAPI *youtubeAPI;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<VideoItemMO*> *videoItems;
@property (nonatomic, copy) NSString *query;
@property (nonatomic, copy) NSString *nextPageToken;

@end

@implementation MEKSearchResultsViewController

- (instancetype)initWithAPI: (MEKYouTubeAPI*) youtubeAPI andQuery:(NSString *)query
{
    self = [super init];
    if (self)
    {
        _query = [query copy];

        _youtubeAPI = youtubeAPI;
        _youtubeAPI.delegate = self;
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

- (NSManagedObjectContext*) coreDataContext
{
    return self.playerController.coreDataContext;
}

#pragma mark - Private

- (void)resetSearch
{
    self.nextPageToken = @"";
    self.videoItems = @[];
    [self.tableView reloadData];
}

- (NSArray<VideoItemMO*>*)videoItemsFromJSONArray: (NSArray*) videosJSON
{
    NSMutableArray *videos = @[].mutableCopy;

    for (NSDictionary *videoJSON in videosJSON)
    {
        VideoItemMO *video = [VideoItemMO disconnectedEntityWithContext:self.coreDataContext];
        [video setupWithDictionary:videoJSON];

        [videos addObject:video];
    }

    return videos;
}

- (void)updateTableView: (UITableView*)tableView insertIndexPaths: (NSArray<NSIndexPath*>*)indexPaths loaderFromIndexPath: (NSIndexPath*) fromIndexPath loaderToIndexPath: (NSIndexPath*) toIndexPath
{
    [tableView performBatchUpdates:^{
        if (self.nextPageToken)
        {
            [tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        }
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    } completion:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.query;
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKVideoItemTableViewCell class] forCellReuseIdentifier:MEKVideoItemTableViewCellID];
    [self.tableView registerClass:[MEKLoaderTableViewCell class] forCellReuseIdentifier:MEKLoaderTableViewCellID];

    [self.view addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self resetSearch];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row == self.videoItems.count)
    {
        MEKLoaderTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MEKLoaderTableViewCellID forIndexPath:indexPath];
        return cell;
    }

    if (indexPath.row < self.videoItems.count)
    {
        MEKVideoItemTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MEKVideoItemTableViewCellID forIndexPath:indexPath];
        VideoItemMO *item = self.videoItems[indexPath.row];
        [cell setWithVideoItem:item];
        return cell;
    }

    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videoItems.count + (self.nextPageToken ? 1 : 0);
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.videoItems.count)
    {
        return [MEKLoaderTableViewCell height];
    }

    if (indexPath.row <= self.videoItems.count)
    {
        return [MEKVideoItemTableViewCell height];
    }

    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    VideoItemMO *item = self.videoItems[indexPath.row];
    [self.playerController openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell isKindOfClass:[MEKLoaderTableViewCell class]])
    {
        return;
    }

    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.youtubeAPI searchVideosForQuery:self.query searchType:MEKYouTubeSearchQuery maxResults:MEKResultsCount pageToken:self.nextPageToken];
}

#pragma mark - MEKYouTubeDelegate

- (void)youTubeVideosDidSearch:(NSArray *)videoIds nextPageToken:(NSString *)pageToken
{
    self.nextPageToken = pageToken;
    [self.youtubeAPI loadDataForVideos:videoIds];
}

- (void)youTubeVideosDidLoad:(NSArray *)videos
{
    NSIndexPath *loaderFromIndexPath = [NSIndexPath indexPathForRow:(self.videoItems.count) inSection:0];
    NSIndexPath *loaderToIndexPath = [NSIndexPath indexPathForRow:(self.videoItems.count + videos.count) inSection:0];
    NSMutableArray *indexPaths = @[].mutableCopy;
    for (int i = 0; i < videos.count; ++i)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:(self.videoItems.count + i) inSection:0]];
    }

    self.videoItems = [self.videoItems arrayByAddingObjectsFromArray:[self videoItemsFromJSONArray:videos]];

    [self updateTableView: self.tableView insertIndexPaths:indexPaths loaderFromIndexPath:loaderFromIndexPath loaderToIndexPath:loaderToIndexPath];
}

@end
