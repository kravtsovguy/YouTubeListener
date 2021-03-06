//
//  MEKGlobalSearchResultsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 22/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKGlobalSearchResultsViewController.h"
#import "MEKVideoItemTableViewController+Private.h"
#import "MEKYouTubeAPI.h"

static NSUInteger const MEKResultsCount = 10;

@interface MEKGlobalSearchResultsViewController () <MEKYouTubeDelegate>

@property (nonatomic, copy) NSString *nextPageToken;
@property (nonatomic, copy) NSArray <NSDictionary *> *jsonVideoItems;

@end

@implementation MEKGlobalSearchResultsViewController

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _youtubeAPI = [[MEKYouTubeAPI alloc] init];
        _youtubeAPI.delegate = self;
    }
    return self;
}

- (void)setQuery:(NSString *)query
{
    super.query = [query copy];
    [self p_reset];
}

- (void)setVideoItems:(NSArray *)videoItems
{
    super.videoItems = videoItems;
    self.infoView.infoLabel.text = @"searching...";
}

#pragma mark - MEKVideoItemActionProtocol

- (void)videoItemRemoveFromLibrary:(VideoItemMO *)item
{
    [self p_checkVideos];
}

#pragma mark - MEKTableViewControllerInputProtocol

- (void)updateData
{
    [self.youtubeAPI cancel];
    [self.youtubeAPI searchVideosForQuery:self.query searchType:MEKYouTubeSearchQuery maxResults:MEKResultsCount pageToken:self.nextPageToken];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self p_reset];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self p_checkVideos];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row + 1 < self.videoItems.count)
    {
        return;
    }

    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self updateData];
}

#pragma mark - MEKYouTubeDelegate

- (void)youTubeVideosDidSearch:(NSArray *)videoIds nextPageToken:(NSString *)pageToken
{
    self.nextPageToken = pageToken;
    [self.youtubeAPI loadDataForVideos:videoIds];
}

- (void)youTubeVideosDidLoad:(NSArray *)videos
{
    NSMutableArray *indexPaths = @[].mutableCopy;

    [videos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:(self.videoItems.count + idx) inSection:0]];
    }];

    self.jsonVideoItems = [self.jsonVideoItems arrayByAddingObjectsFromArray:videos];
    self.videoItems = [self.videoItems arrayByAddingObjectsFromArray:[VideoItemMO videoItemsFromJSON:videos withContext:self.coreDataContext]];

    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private

- (void)p_reset
{
    self.nextPageToken = @"";
    self.jsonVideoItems = @[];
    self.videoItems = @[];
    [self.tableView reloadData];

    [self updateData];
}

- (void)p_checkVideos
{
    NSMutableArray<VideoItemMO *> *videoItems = [self.videoItems mutableCopy];
    NSMutableArray<NSIndexPath *> *indexPaths = @[].mutableCopy;

    [self.jsonVideoItems enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!videoItems[idx].isFault)
        {
            return;
        }

        videoItems[idx] = [VideoItemMO videoItemsFromJSON:@[obj] withContext:self.coreDataContext].firstObject;
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];

    self.videoItems = videoItems;

    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

@end
