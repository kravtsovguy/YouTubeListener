//
//  MEKImageDownloadController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MEKCombinedCache;
@class MEKImageDownloadController;

@protocol MEKImageDownloadControllerDelegate

- (void)imageDownloadController: (MEKImageDownloadController *)controller didLoadImage: (UIImage *)image fromCache: (BOOL)cached;

@end

@interface MEKImageDownloadController : NSObject

@property (nonatomic, weak) id<MEKImageDownloadControllerDelegate> delegate;
@property (nonatomic, strong, readonly) MEKCombinedCache *cache;

- (instancetype)initWithCache: (MEKCombinedCache *)cache;
- (void)downloadImageFromURL: (NSURL *)url;
- (BOOL)hasDownloading;
- (void)cancelDownloading;

@end
