//
//  MEKPlaylistActionController+Alerts.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistActionController+Alerts.h"
#import "MEKPlaylistActionController+Private.h"
#import "MEKModalPlaylistsViewController.h"
#import "PlaylistMO+CoreDataClass.h"

@interface MEKPlaylistActionController (Delegates) <MEKModalPlaylistsViewControllerDelegate>

@end

@implementation MEKPlaylistActionController (Delegates)

- (void)modalPlaylistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist forVideoItem:(VideoItemMO *)item
{
    [self playlist:playlist addVideoItem:item];
}

@end

@implementation MEKPlaylistActionController (Alerts)

- (void)showCreatePlaylistDialog
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        NSString *name = alert.textFields[0].text;
        [self playlistCreateWithName:name];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];

    [alert addAction:submit];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.placeholder = @"Playlist Name";
    }];

    [self.alertController showViewController:alert];
}

- (void)showRenamePlaylistDialog:(PlaylistMO *)playlist
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        NSString *name = alert.textFields[0].text;
        [self playlistRename:playlist toName:name];
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

    [self.alertController showViewController:alert];
}

- (void)showRemovePlaylistDialog:(PlaylistMO *)playlist
{
    UIAlertAction *submit =[self.alertController actionWithTitle:@"Delete" handler:^{
        [self playlistRemove:playlist];
    }];

    [self.alertController showDialogWithTitle:@"" message:@"Delete the playlist?" actions:@[submit]];
}

- (void)showChoosePlaylistDialogForVideoItem:(VideoItemMO *)item
{
    MEKModalPlaylistsViewController *playlistsController = [[MEKModalPlaylistsViewController alloc] initWithVideoItem:item];
    playlistsController.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    navController.navigationBar.prefersLargeTitles = YES;

    [self.alertController showViewController:navController];
}

@end
