//
//  MEKCombinedActionController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 16/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCombinedActionController.h"
#import "MEKVideoItemActionController.h"
#import "MEKPlaylistActionController.h"
#import "MEKAlertController.h"

@interface MEKCombinedActionController ()

@end

@implementation MEKCombinedActionController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _videoItemActionController = [[MEKVideoItemActionController alloc] init];
        _playlistActionController = [[MEKPlaylistActionController alloc] init];

        _videoItemActionController.playlistActionController = _playlistActionController;
        _playlistActionController.videoItemActionController = _videoItemActionController;
    }
    
    return self;
}

- (void)showClearLibraryDialog
{
    UIAlertAction *action = [self.alertController actionWithTitle:@"Clear" handler:^{
        [self.videoItemActionController videoItemRemoveAll];
        [self.playlistActionController playlistRemoveAll];
    }];

    [self.alertController showDialogWithTitle:@"" message:@"Clear your library?" actions:@[action]];
}

@end
