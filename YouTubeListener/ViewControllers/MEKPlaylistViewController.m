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

@interface MEKPlaylistViewController () <UITableViewDelegate, UITableViewDataSource, MEKVideoItemTableViewCellDelegate, MEKPlaylistsViewControllerDelegate>

@property (nonatomic, readonly) MEKPlayerController *playerController;
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

- (void)videoItemAddToPlaylistPressed:(VideoItemMO *)item
{
    self.currentItem = item;
    
    MEKPlaylistsViewController *playlistsController = [[MEKPlaylistsViewController alloc] initModal];
    playlistsController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)videoItemDownloadPressed:(VideoItemMO *)item
{
    
}

- (void)playlistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist
{
    [playlist addVideoItem:self.currentItem];
}

@end
