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
#import "MEKInfoView.h"

static NSString * const MEKPlaylistTableViewCellID = @"MEKPlaylistTableViewCell";
static NSString * const MEKPlaylistTableViewHeaderID = @"MEKPlaylistTableViewHeader";

@interface MEKPlaylistsViewController () <UIViewControllerPreviewingDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *playlists;
@property (nonatomic, strong) MEKPlaylistTableViewCell *headerCell;
@property (nonatomic, strong) id<UIViewControllerPreviewing> previewingContext;

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
    
    return appDelegate.playerController;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"PLAYLISTS";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToPlaylistPressed:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    UIBarButtonItem *goItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(goToUrlPressed:)];
    self.navigationItem.leftBarButtonItem = goItem;

    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView =[UIView new];
    [self.tableView registerClass:[MEKPlaylistTableViewCell class] forCellReuseIdentifier:MEKPlaylistTableViewCellID];
    [self.tableView registerClass:[MEKPlaylistTableViewCell class] forCellReuseIdentifier:MEKPlaylistTableViewHeaderID];
    
    self.tableView.sectionHeaderHeight = [MEKPlaylistTableViewCell height];
    
    MEKInfoView *infoView = [[MEKInfoView alloc] initWithFrame:CGRectMake(0, 0, 0, [MEKPlaylistTableViewCell height])];
    infoView.infoLabel.text = @"Copy URL from YouTube\nthen press Play icon";
    
    self.tableView.tableFooterView = infoView;
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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

- (void)showRenamePlaylistDialogAtIndexPath: (NSIndexPath *) indexPath
{
    PlaylistMO *playlist = self.playlists [indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        NSString *name = alert.textFields[0].text;
        [self renamePlaylistAtIndexPath:indexPath toName:name];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:submit];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.placeholder = @"Playlist Name";
        textField.text = playlist.name;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)renamePlaylistAtIndexPath: (NSIndexPath *) indexPath toName: (NSString *) name
{
    PlaylistMO *playlist = self.playlists [indexPath.row];
    
    if ([playlist.name isEqualToString:name])
    {
        return;
    }

    if (![playlist rename:name])
    {
        [self showInvalidNameAlertForName:name];
        return;
    }
    
    [self.tableView reloadData];
}

- (void)showDeletePlaylistDialogAtIndexPath: (NSIndexPath *) indexPath
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Delete the playlist?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        [self deletePlaylistAtIndexPath:indexPath];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:submit];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deletePlaylistAtIndexPath: (NSIndexPath *) indexPath
{
    PlaylistMO *playlist = self.playlists [indexPath.row];
    [playlist deleteObject];
    
    NSMutableArray *playlists = self.playlists.mutableCopy;
    [playlists removeObjectAtIndex:indexPath.row];
    self.playlists = playlists;
    
    [self.tableView reloadData];
}

- (void)showInvalidSearchAlertForURL: (NSURL*) url
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Can't Parse Given Url"
                                                                   message:url.absoluteString
                                                            preferredStyle:UIAlertControllerStyleAlert];
    

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showInvalidNameAlertForName: (NSString*) name
{
    [self showInvalidNameAlertForName:name withText:@"Playlist with this name already exists"];
}

- (void)showInvalidNameAlertForName: (NSString*) name withText: (NSString*) text
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text
                                                                   message:name
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                     handler:nil];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)addPlaylistWithName: (NSString *) name
{
    NSString *correctName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (correctName.length == 0)
    {
        [self showInvalidNameAlertForName:correctName withText:@"Incorrect playlist name"];
        return NO;
    }
    
    PlaylistMO *player = [PlaylistMO playlistWithName:correctName withContext:self.coreDataContext];
    if (!player)
    {
        [self showInvalidNameAlertForName:correctName];
        return NO;
    }
    
    [self loadPlaylists];
    return YES;
}

#pragma mark - Selectors

- (void)goToUrlPressed: (id) sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (![pasteboard hasStrings])
    {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:pasteboard.string];
    
    BOOL isOK = [self.playerController openURL:url withVisibleState:MEKPlayerVisibleStateMaximized];
    
    if (!isOK)
    {
        [self showInvalidSearchAlertForURL:url];
    }
}

- (void)addToPlaylistPressed: (id) sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        NSString *name = alert.textFields[0].text;
        [self addPlaylistWithName:name];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:submit];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
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
    
    MEKPlaylistTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MEKPlaylistTableViewCellID forIndexPath:indexPath];
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
    MEKPlaylistTableViewCell *cell = self.headerCell;
    
    if (!cell)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:MEKPlaylistTableViewHeaderID];
        
        cell.backgroundColor = [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.alpha = 1;
        blurEffectView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), [MEKPlaylistTableViewCell height]);
        [cell insertSubview:blurEffectView atIndex:0];
        
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recentTapped:)];
        
        [cell addGestureRecognizer:singleTapRecognizer];
        
        self.headerCell = cell;
    }

    NSArray<VideoItemMO*> *items = [VideoItemMO getRecentVideoItemsWithContext:self.coreDataContext];
    
    [cell setWithName:[PlaylistMO recentPlaylistName] itemsCount:items.count imageURL:items.firstObject.thumbnailBig];
    
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Rename" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self showRenamePlaylistDialogAtIndexPath:indexPath];
    }];
    renameAction.backgroundColor = [UIColor lightGrayColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self showDeletePlaylistDialogAtIndexPath:indexPath];
    }];
    
    return @[deleteAction, renameAction];
}

#pragma mark - UITraitCollection

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)])
    {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
        {

            if (!self.previewingContext)
            {
                self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
            }
        }
        else
        {
            [self unregisterForPreviewingWithContext:self.previewingContext];
            self.previewingContext = nil;
        }
    }
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing> )previewingContext viewControllerForLocation:(CGPoint)location
{
    
    CGPoint cellPostion = [self.tableView convertPoint:location fromView:self.view];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPostion];
    if (indexPath)
    {
        PlaylistMO *playlist = self.playlists [indexPath.row];
        MEKPlaylistViewController *controller = [[MEKPlaylistViewController alloc] initWithPlaylist:playlist];

        return controller;
    }
    
    CGRect headerFrame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), [MEKPlaylistTableViewCell height]);
    if (CGRectContainsPoint(headerFrame, cellPostion))
    {
        MEKRecentPlaylistViewController *controller = [MEKRecentPlaylistViewController new];
        
        return controller;
    }
    
    return nil;
}

-(void)previewingContext:(id )previewingContext commitViewController: (UIViewController *)viewControllerToCommit
{
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}

@end
