//
//  MEKPlaylistAlertController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistAlertController.h"
#import "PlaylistMO+CoreDataClass.h"

@implementation MEKPlaylistAlertController

- (void)showCreatePlaylistDialog
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        NSString *name = alert.textFields[0].text;
        [self.delegate playlistCreateWithName:name];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];

    [alert addAction:submit];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.placeholder = @"Playlist Name";
    }];

    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void)showRenameDialogForPlaylist:(PlaylistMO *)playlist
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Rename Playlist"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

        NSString *name = alert.textFields[0].text;
        [self.delegate playlistRename:playlist toName:name];
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

    [self.viewController presentViewController:alert animated:YES completion:nil];
}

- (void)showRemoveDialogForPlaylist:(PlaylistMO *)playlist
{
    UIAlertAction *submit =[self actionWithTitle:@"Delete" handler:^{
        [self.delegate playlistForceRemove:playlist];
    }];

    [self showDialogWithTitle:@"" message:@"Delete the playlist?" actions:@[submit]];
}

@end
