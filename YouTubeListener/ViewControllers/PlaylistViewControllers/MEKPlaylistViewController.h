//
//  MEKPlaylistViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistMO+CoreDataClass.h"
#import "UIViewController+VideoItemActions.h"
#import "MEKPlayerController.h"
#import "MEKVideoItemDownloadController.h"

@interface MEKPlaylistViewController : UIViewController

@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;
@property (nonatomic, readonly) MEKPlayerController *playerController;
@property (nonatomic, readonly) MEKVideoItemDownloadController *downloadController;
@property (nonatomic, readonly) PlaylistMO *playlist;

- (instancetype)initWithPlaylist: (PlaylistMO*) playlist;

@end
