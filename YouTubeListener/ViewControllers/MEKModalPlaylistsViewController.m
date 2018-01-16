//
//  MEKModalPlaylistsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKModalPlaylistsViewController.h"

@interface MEKModalPlaylistsViewController ()

@end

@implementation MEKModalPlaylistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Choose Playlist";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelView:)];
    self.navigationItem.leftBarButtonItem = item;
    
    self.tableView.sectionHeaderHeight = 0;
}

- (void)cancelView: (id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistMO *playlist = self.playlists [indexPath.row];
    

    if ([self.delegate respondsToSelector:@selector(playlistsViewControllerDidChoosePlaylist:)])
    {
        [self.delegate playlistsViewControllerDidChoosePlaylist:playlist];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[];
}





@end
