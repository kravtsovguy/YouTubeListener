//
//  MEKPlaylistsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEKPlayerController;

@interface MEKPlaylistsViewController : UIViewController

@property (nonatomic, readonly) NSManagedObjectContext *coreDataContext;
@property (nonatomic, readonly) MEKPlayerController *playerController;

@end
