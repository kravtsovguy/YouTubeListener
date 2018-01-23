//
//  MEKModalPlaylistsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKModalPlaylistsViewController.h"

@interface MEKPlaylistsViewController (Private) <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *playlists;
@property (nonatomic, strong) id<UIViewControllerPreviewing> previewingContext;

@end


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Choose Playlist";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelView:)];
    self.navigationItem.leftBarButtonItem = item;
    
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - Selectors

- (void)cancelView: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
