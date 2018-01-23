//
//  MEKVideoItemDownloadController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoItemMO+CoreDataClass.h"
#import "MEKDownloadController.h"

@protocol MEKVideoItemDownloadControllerDelegate <NSObject>

@optional
- (void)videoItemDownloadControllerProgress: (double) progress forVideoItem: (VideoItemMO *) item;
- (void)videoItemDownloadControllerDidFinishWithError: (NSError*) error forVideoItem: (VideoItemMO *) item;

@end

@interface MEKVideoItemDownloadController : NSObject

@property (nonatomic, weak) id<MEKVideoItemDownloadControllerDelegate> delegate;
@property (nonatomic, readonly) MEKDownloadController *downloadController;

- (instancetype)initWithDownloadController: (MEKDownloadController *) downloadController;

- (void)downloadVideoItem: (VideoItemMO *) item withQuality: (VideoItemQuality) quality;
- (void)cancelDownloadingVideoItem: (VideoItemMO *) item;
- (double)getProgressForVideoItem: (VideoItemMO *) item;
- (BOOL)downloadingVideoItem: (VideoItemMO *) item;

@end
