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

@interface MEKPlaylistsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *playlists;
@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, strong) MEKPlaylistTableViewCell *sectionCell;
@property (nonatomic, strong) PlaylistMO *recentPlaylist;

@end

@implementation MEKPlaylistsViewController

-(instancetype)initModal
{
    self = [super init];
    if (self)
    {
        _isModal = YES;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isModal = NO;
    }
    
    return self;
}

- (NSManagedObjectContext*) coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    NSPersistentContainer *container = ((AppDelegate*)(application.delegate)).persistentContainer;
    
    NSManagedObjectContext *context = container.viewContext;
    
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PLAYLISTS";
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlaylist:)];
    self.navigationItem.rightBarButtonItem = item;
    
    if (self.isModal)
    {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelView:)];
        self.navigationItem.leftBarButtonItem = item;
    }
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKPlaylistTableViewCell class] forCellReuseIdentifier:@"MEKPlaylistTableViewCell"];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

//    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
//    header.backgroundColor = UIColor.redColor;
//    self.tableView.tableHeaderView = header;
    self.tableView.sectionHeaderHeight = [MEKPlaylistTableViewCell height];
    
    if (self.isModal)
    {
        self.tableView.sectionHeaderHeight = 0;
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPlaylists];
}

- (void)cancelView: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateData
{
    self.recentPlaylist = [PlaylistMO getRecentPlaylistWithContext:self.coreDataContext];
    self.playlists = [PlaylistMO getPlaylistsWithContext:self.coreDataContext];
}

- (void)loadPlaylists
{
    [self updateData];
    [self.tableView reloadData];
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


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MEKPlaylistTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MEKPlaylistTableViewCell" forIndexPath:indexPath];
    
    if (!self.isModal)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    PlaylistMO *playlist = self.playlists[indexPath.row];
    [cell setWithPlaylist:playlist andVideoItem:[playlist getFirstVideoItem]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlaylistMO *playlist = self.playlists [indexPath.row];
    
    
    if ([self.delegate respondsToSelector:@selector(playlistsViewControllerDidChoosePlaylist:)])
    {
        [self.delegate playlistsViewControllerDidChoosePlaylist:playlist];
    }
    
    if (self.isModal)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!self.sectionCell)
    {
        MEKPlaylistTableViewCell *cell = [[MEKPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MEKPlaylistTableViewCell2"];
        cell.backgroundColor = [UIColor colorWithRed:1 green:0.9 blue:0.9 alpha:1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recentTapped:)];

        [cell addGestureRecognizer:singleTapRecognizer];
        
        self.sectionCell = cell;
    }
    
    [self.sectionCell setWithPlaylist:self.recentPlaylist andVideoItem:[self.recentPlaylist getFirstVideoItem]];
    return self.sectionCell;
}

- (void)recentTapped:(UIGestureRecognizer *)gestureRecognizer
{
    MEKPlaylistViewController *controller = [[MEKPlaylistViewController alloc] initWithPlaylist:self.recentPlaylist];
    
    [self.navigationController pushViewController:controller animated:YES];
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


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isModal)
    {
        return @[];
    }
    
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
