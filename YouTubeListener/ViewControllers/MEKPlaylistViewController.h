//
//  MEKPlaylistViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistMO+CoreDataClass.h"

@interface MEKPlaylistViewController : UIViewController

-(instancetype)initWithPlaylist: (PlaylistMO*) playlist;

@end
