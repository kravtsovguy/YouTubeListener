//
//  MEKPlaylistsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistMO+CoreDataClass.h"

@interface MEKPlaylistsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *playlists;

@end
