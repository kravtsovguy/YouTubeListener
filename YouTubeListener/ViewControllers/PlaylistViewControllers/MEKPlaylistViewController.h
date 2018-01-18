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
#import "AppDelegate.h"

@interface MEKPlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;
@property (nonatomic, readonly) MEKPlayerController *playerController;
@property (nonatomic, readonly) MEKDownloadController *downloadController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *items;

- (instancetype)initWithPlaylist: (PlaylistMO*) playlist;

@end
