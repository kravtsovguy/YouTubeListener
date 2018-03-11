//
//  MEKVideoItemAlertController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 08/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MEKPropertyManagedObjectContextProtocol.h"
#import "MEKVideoItemActionProtocol.h"

@interface MEKVideoItemAlertController : NSObject <MEKPropertyManagedObjectContextProtocol>

@property (nonatomic, weak) id<MEKVideoItemActionProtocol> delegate;
@property (nonatomic, strong, readonly) UIViewController *viewController;

- (instancetype)initWithViewController: (UIViewController *)viewController;

- (void)showActionsForVideoItem: (VideoItemMO *)item;
- (void)showPlaylistSelectionForVideoItem:(VideoItemMO *)item;
- (void)showDownloadingDialogForVideoItem: (VideoItemMO*)item;

@end
