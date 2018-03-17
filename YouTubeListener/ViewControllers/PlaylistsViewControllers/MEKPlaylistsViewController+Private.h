//
//  MEKPlaylistsViewController+Private.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 25/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistsViewController.h"
#import "PlaylistMO+CoreDataClass.h"
#import "MEKCombinedActionController.h"
#import "MEKInfoView.h"

@interface MEKPlaylistsViewController () <UIViewControllerPreviewingDelegate, MEKPlaylistActionProtocol>

@property (nonatomic, copy) NSArray<PlaylistMO*> *playlists;
@property (nonatomic, strong) MEKInfoView *infoView;
@property (nonatomic, strong) MEKCombinedActionController *actionController;
@property (nonatomic, strong) id<UIViewControllerPreviewing> previewingContext;

@end
