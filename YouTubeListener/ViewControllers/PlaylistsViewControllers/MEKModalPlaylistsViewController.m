//
//  MEKModalPlaylistsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKModalPlaylistsViewController.h"
#import "MEKPlaylistsViewController+Private.h"

@interface MEKModalPlaylistsViewController ()

@property (nonatomic, strong) VideoItemMO *item;

@end

@implementation MEKModalPlaylistsViewController

#pragma mark - init

- (instancetype)initWithVideoItem:(VideoItemMO *)item
{
    self = [super init];
    if (self)
    {
        _item = item;
    }
    
    return self;
}

#pragma mark - UIViewController

- (NSString *)title
{
    return @"Choose Playlist";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(p_cancelView:)];
    self.navigationItem.leftBarButtonItem = item;
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistMO *playlist = self.playlists [indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(modalPlaylistsViewControllerDidChoosePlaylist:forVideoItem:)])
    {
        [self.delegate modalPlaylistsViewControllerDidChoosePlaylist:playlist forVideoItem:self.item];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[];
}

#pragma mark - UITraitCollection

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (!self.previewingContext)
    {
        return;
    }
    
    [self unregisterForPreviewingWithContext:self.previewingContext];
    self.previewingContext = nil;
}

#pragma mark - Private

- (void)p_cancelView: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
