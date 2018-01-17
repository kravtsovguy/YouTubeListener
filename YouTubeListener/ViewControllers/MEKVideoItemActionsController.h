//
//  MEKVideoItemActionsController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 18/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItemMO+CoreDataClass.h"
#import "MEKDownloadController.h"

@interface MEKVideoItemActionsController : UIViewController

@property (nonatomic, strong) MEKDownloadController *downloadController;

- (instancetype)initWithVideoItem: (VideoItemMO*) item;

@end
