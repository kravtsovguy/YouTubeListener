//
//  UIViewController+VideoItemActions.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 18/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItemMO+CoreDataClass.h"

@interface UIViewController(VideoItemActions)

- (void)showDownloadingDialogForVideoItem: (VideoItemMO*) item handler:(void (^)(VideoItemQuality quality))handler;
- (void)showQualityDialogForCurrentQuality: (VideoItemQuality)currentQuality handler:(void (^)(VideoItemQuality quality))handler;
- (void)choosePlaylistForVideoItem: (VideoItemMO*) item;

@end