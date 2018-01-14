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

@interface MEKPlaylistViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PlaylistMO *playlist;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *videoItems;
@property (nonatomic, readonly) BOOL isEditable;

@end

@implementation MEKPlaylistViewController


-(instancetype)initWithPlaylist:(PlaylistMO *)playlist
{
    self = [super init];
    if (self)
    {
        _playlist = playlist;
    }
    
    return self;
}

-(BOOL)isEditable
{
    return ![self.playlist.name isEqualToString:[PlaylistMO recentPlaylistName]];
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
    
    AppDelegate *appDelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.player openURL:url withVisibleState:MEKPlayerVisibleStateMinimized];
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

@end
