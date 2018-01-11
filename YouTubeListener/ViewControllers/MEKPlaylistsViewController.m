//
//  MEKPlaylistsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistsViewController.h"
#import <Masonry/Masonry.h>
#import "MEKPlaylistTableViewCell.h"
#import "PlaylistMO+CoreDataClass.h"
#import "AppDelegate.h"
#import "MEKPlaylistViewController.h"
#import "MEKVideoItemsController.h"

@interface MEKPlaylistsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly) MEKVideoItemsController *controller;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *playlists;

@end

@implementation MEKPlaylistsViewController

-(MEKVideoItemsController *)controller
{
    UIApplication *application = [UIApplication sharedApplication];
    MEKVideoItemsController *controller = ((AppDelegate*)(application.delegate)).videoItemsController;
    
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PLAYLISTS";
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlaylist:)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKPlaylistTableViewCell class] forCellReuseIdentifier:@"MEKPlaylistTableViewCell"];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self loadPlaylists];
}

- (void)loadPlaylists
{
    self.playlists = [self.controller getPlaylists];
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addPlaylist: (id) sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self.controller addPlaylistWithName:alert.textFields[0].text];
                                                       [self loadPlaylists];
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    
    [alert addAction:submit];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Playlist Name";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MEKPlaylistTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MEKPlaylistTableViewCell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    PlaylistMO *playlist = self.playlists[indexPath.row];
    [cell setWithPlaylist:playlist];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlaylistMO *playlist = self.playlists [indexPath.row];
    MEKPlaylistViewController *controller = [[MEKPlaylistViewController alloc] initWithPlaylist:playlist];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playlists.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEKPlaylistTableViewCell height];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.controller deletePlaylist: self.playlists [indexPath.row]];
        [self loadPlaylists];
    }
}

@end
