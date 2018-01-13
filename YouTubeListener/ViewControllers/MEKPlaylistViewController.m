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
#import "MEKVideoItemsController.h"
#import "MEKVideoItemTableViewCell.h"

@interface MEKPlaylistViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly) MEKVideoItemsController *controller;
@property (nonatomic, strong) PlaylistMO *playlist;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *videoItems;

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

-(MEKVideoItemsController *)controller
{
    UIApplication *application = [UIApplication sharedApplication];
    MEKVideoItemsController *controller = ((AppDelegate*)(application.delegate)).videoItemsController;
    
    return controller;
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
    
    [self loadItems];
}

- (void)loadItems
{
    self.videoItems = [self.controller getVideoItemsForPlaylist:self.playlist];
    //self.playlist = [self.controller getPlaylistForName:self.playlist.name];
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.controller deleteVideoItem:self.videoItems[indexPath.row] fromPlaylist:self.playlist];
        [self loadItems];
    }
}

@end
