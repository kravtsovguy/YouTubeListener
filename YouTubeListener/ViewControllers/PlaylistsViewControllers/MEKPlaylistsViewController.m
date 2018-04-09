//
//  MEKPlaylistsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistsViewController+Private.h"
#import "MEKPlaylistViewController.h"
#import "MEKPlaylistTableViewCell.h"
#import "MEKPlaylistActionController.h"

@implementation MEKPlaylistsViewController

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _actionController = [[MEKCombinedActionController alloc] init];
        _actionController.playlistActionController.delegate = self;
    }
    return self;
}

#pragma mark - Properties

- (NSManagedObjectContext*)coreDataContext
{
    return self.actionController.coreDataContext;
}

- (void)setPlaylists:(NSArray<PlaylistMO *> *)playlists
{
    self.infoView.infoLabel.text = [NSString stringWithFormat:@"%@ playlists", @(playlists.count)];
    _playlists = [playlists copy];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.infoView = [[MEKInfoView alloc] initWithFrame:CGRectMake(0, 0, 0, 60)];
    self.tableView.tableFooterView = self.infoView;
    [self.tableView registerClass:[MEKPlaylistTableViewCell class] forCellReuseIdentifier:NSStringFromClass([MEKPlaylistTableViewCell class])];
}

#pragma mark - MEKTableViewControllerInputProtocol

- (void)updateData
{
    self.playlists = @[];
}

#pragma mark MEKPlaylistActionProtocol

- (void)playlistRename:(PlaylistMO *)playlist toName:(NSString *)name
{
    [self updateData];
    [self.tableView reloadData];
}

- (void)playlistRemove:(PlaylistMO *)playlist
{
    NSMutableArray *playlists = self.playlists.mutableCopy;
    [playlists removeObject:playlist];
    self.playlists = playlists;
    
    [self.tableView reloadData];
}

- (void)playlistCreateWithName:(NSString *)name
{
    [self updateData];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    MEKPlaylistTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MEKPlaylistTableViewCell class])];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    PlaylistMO *playlist = self.playlists[indexPath.row];
    NSArray<VideoItemMO *> *videoItemArray = [playlist videoItems];

    if (self.offlineMode)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hasDownloaded = YES"];
        videoItemArray = [videoItemArray filteredArrayUsingPredicate:predicate];
    }

    [cell setWithName:playlist.name itemsCount:videoItemArray.count imageURL:videoItemArray.firstObject.thumbnailBig];
    
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
    MEKPlaylistViewController *viewController = [[MEKPlaylistViewController alloc] initWithPlaylist:playlist];
    viewController.offlineMode = self.offlineMode;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEKPlaylistTableViewCell height];
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
        MEKPlaylistViewController *viewController = [[MEKPlaylistViewController alloc] initWithPlaylist:playlist];
        viewController.offlineMode = self.offlineMode;

        return viewController;
    }

    return nil;
}

-(void)previewingContext:(id )previewingContext commitViewController: (UIViewController *)viewControllerToCommit
{
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}

@end
