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
#import "MEKRecentPlaylistViewController.h"

@interface MEKPlaylistsViewController ()

@property (nonatomic, strong) MEKPlaylistTableViewCell *sectionCell;

@end

@implementation MEKPlaylistsViewController

#pragma mark - Properties

- (NSManagedObjectContext*) coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;
    
    NSPersistentContainer *container = appDelegate.persistentContainer;
    return container.viewContext;
}

- (MEKPlayerController *)playerController
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;
    
    return appDelegate.player;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"PLAYLISTS";
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlaylist:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    UIBarButtonItem *goItem = [[UIBarButtonItem alloc] initWithTitle:@"GO" style:UIBarButtonItemStyleDone target:self action:@selector(goToURL:)];
    self.navigationItem.leftBarButtonItem = goItem;

    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKPlaylistTableViewCell class] forCellReuseIdentifier:@"MEKPlaylistTableViewCell"];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.tableView.sectionHeaderHeight = [MEKPlaylistTableViewCell height];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPlaylists];
}

#pragma mark - Private

- (void)updateData
{
    self.playlists = [PlaylistMO getPlaylistsWithContext:self.coreDataContext];
}

- (void)loadPlaylists
{
    [self updateData];
    [self.tableView reloadData];
}

- (void)renamePlaylist: (PlaylistMO*) playlist
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self.tableView setEditing:NO];
                                                       
                                                       [playlist rename:alert.textFields[0].text];
                                                       
                                                       [self loadPlaylists];
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                   }];
    
    [alert addAction:submit];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = playlist.name;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Selectors

- (void)goToURL: (id) sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (![pasteboard hasStrings])
    {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:pasteboard.string];
    
    [self.playerController openURL:url withVisibleState:MEKPlayerVisibleStateMaximized];
}

- (void)addPlaylist: (id) sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                       [PlaylistMO playlistWithName:alert.textFields[0].text withContext:self.coreDataContext];
                                                       
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

- (void)recentTapped:(UIGestureRecognizer *)gestureRecognizer
{
    MEKRecentPlaylistViewController *controller = [MEKRecentPlaylistViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    MEKPlaylistTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MEKPlaylistTableViewCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    PlaylistMO *playlist = self.playlists[indexPath.row];
    [cell setWithPlaylist:playlist andVideoItem:[playlist getFirstVideoItem]];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playlists.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlaylistMO *playlist = self.playlists [indexPath.row];
    MEKPlaylistViewController *controller = [[MEKPlaylistViewController alloc] initWithPlaylist:playlist];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEKPlaylistTableViewCell height];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.sectionCell)
    {
        MEKPlaylistTableViewCell *cell = [[MEKPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MEKPlaylistTableViewCell2"];
        cell.backgroundColor = [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.1];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.alpha = 1;
        blurEffectView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), [MEKPlaylistTableViewCell height]);
        [cell insertSubview:blurEffectView atIndex:0];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recentTapped:)];

        [cell addGestureRecognizer:singleTapRecognizer];
        
        self.sectionCell = cell;
    }
    
    NSArray<VideoItemMO*> *items = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];
    
    [self.sectionCell setWithName:[PlaylistMO recentPlaylistName] itemsCount:items.count imageURL:items.firstObject.thumbnailBig];
    
    return self.sectionCell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self renamePlaylist:self.playlists [indexPath.row]];
        
    }];
    moreAction.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        PlaylistMO *playlist = self.playlists [indexPath.row];
        [playlist deleteObject];
        
        NSMutableArray *playlists = self.playlists.mutableCopy;
        [playlists removeObjectAtIndex:indexPath.row];
        self.playlists = playlists;
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return @[deleteAction, moreAction];
}

@end
