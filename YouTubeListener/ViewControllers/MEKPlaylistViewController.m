//
//  MEKPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistViewController.h"
#import "VideoItemMO+CoreDataClass.h"
#import "AppDelegate.h"
#import <Masonry/Masonry.h>
#import "MEKVideoItemTableViewCell.h"
#import "MEKPlaylistsViewController.h"
#import "VideoItemDelegate.h"

@interface MEKPlaylistViewController () <UITableViewDelegate, UITableViewDataSource, MEKVideoItemDelegate, MEKPlaylistsViewControllerDelegate, MEKDownloadControllerDelegate, YouTubeParserDelegate>

@property (nonatomic, readonly) MEKPlayerController *playerController;
@property (nonatomic, readonly) MEKDownloadController *downloadController;
@property (nonatomic, strong) YouTubeParser *parser;
@property (nonatomic, strong) PlaylistMO *playlist;
@property (nonatomic, weak) VideoItemMO *currentItem;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *videoItems;
@property (nonatomic, readonly) BOOL isEditable;



@end

@implementation MEKPlaylistViewController


- (instancetype)initWithPlaylist:(PlaylistMO *)playlist
{
    self = [super init];
    if (self)
    {
        _playlist = playlist;
        
        _parser = [YouTubeParser new];
        _parser.delegate = self;
    }
    
    return self;
}

- (BOOL)isEditable
{
    return ![self.playlist.name isEqualToString:[PlaylistMO recentPlaylistName]];
}

- (MEKPlayerController *)playerController
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;
    MEKPlayerController *player = appDelegate.player;
    return player;
}

- (MEKDownloadController *)downloadController
{
    return self.playerController.downloadController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.playlist.name;
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKVideoItemTableViewCell class] forCellReuseIdentifier:@"MEKVideoItemTableViewCell"];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.downloadController.delegate = self;
    [self loadItems];
}

- (void)updateData
{
    self.videoItems = [self.playlist getVideoItems];
}

- (void)loadItems
{
    [self updateData];
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MEKVideoItemTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MEKVideoItemTableViewCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    VideoItemMO *item = self.videoItems[indexPath.row];
    
    [cell setWithPlaylist:item];
    
    double progress = [self.downloadController getProgressForKey:item.videoId];
    
    if ([item hasDownloaded])
        progress = 1;
    
    [cell setDownloadProgress:progress];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videoItems.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEKVideoItemTableViewCell height];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VideoItemMO *item = self.videoItems[indexPath.row];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://youtu.be/%@", item.videoId]];
    
    [self.playerController openURL:url withVisibleState:MEKPlayerVisibleStateMinimized];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!self.isEditable)
    {
        return @[];
    }
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self.playlist deleteVideoItem:self.videoItems[indexPath.row]];
        
        NSMutableArray *items = self.videoItems.mutableCopy;
        [items removeObjectAtIndex:indexPath.row];
        self.videoItems = items;
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return @[deleteAction];
}

- (void)videoItemAddToPlaylist:(VideoItemMO *)item
{
    self.currentItem = item;
    
    MEKPlaylistsViewController *playlistsController = [[MEKPlaylistsViewController alloc] initModal];
    playlistsController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)videoItemDownload:(VideoItemMO *)item
{
    if (item.urls)
    {
        [self.downloadController downloadDataFromURL:item.urls[@(YouTubeParserVideoQualitySmall144)] forKey:item.videoId];
    }
    else
    {
        [self.parser loadVideoItem:item];
    }
}

- (void)videoItemCancelDownload:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadForKey:item.videoId];
}

- (void)playlistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist
{
    [playlist addVideoItem:self.currentItem];
}

- (void)downloadControllerProgress:(double)progress forKey:(NSString *)key
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (MEKVideoItemTableViewCell *cell in self.tableView.visibleCells)
        {
            VideoItemMO *item = [cell getItem];
            if ([key isEqualToString:item.videoId])
            {
                [cell setDownloadProgress:progress];
                return;
            }
        }
    });
}

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoId == %@", key];
    VideoItemMO *item = [self.videoItems filteredArrayUsingPredicate:predicate].firstObject;
    [item saveTempPathURL:url];
}

- (void)youtubeParserItemDidLoad:(VideoItemMO *)item
{
    [self videoItemDownload:item];
}

@end
