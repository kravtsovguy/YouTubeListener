//
//  MEKPlaylistsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistMO+CoreDataClass.h"

@protocol MEKPlaylistsViewControllerDelegate <NSObject>

@optional
- (void)playlistsViewControllerDidChoosePlaylist: (PlaylistMO*) playlist;

@end

@interface MEKPlaylistsViewController : UIViewController

@property (nonatomic, weak) id<MEKPlaylistsViewControllerDelegate> delegate;

-(instancetype)initModal;

@end
