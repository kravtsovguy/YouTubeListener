//
//  MEKImageLoader.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 05/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEKAsyncCombinedCache;
@class MEKImageLoader;
@class UIImage;

typedef void (^ImageLoaderCompletionBlock) (UIImage *image, BOOL cached);

@protocol MEKImageDownloaderDelegate <NSObject>

- (void)imageDownloader: (MEKImageLoader *)downloader didLoadImage: (UIImage *)image forUrl: (NSURL *)url fromCache: (BOOL)cached;

@end

@interface MEKImageLoader : NSObject

@property (nonatomic, weak) id<MEKImageDownloaderDelegate> delegate;

+ (instancetype)sharedInstance;
- (instancetype)initWithCache: (MEKAsyncCombinedCache *)cache;
- (void)loadImageFromUrl: (NSURL *)url;
- (void)loadImageFromUrl: (NSURL *)url completion: (ImageLoaderCompletionBlock)completion;
- (void)cancelLoadForUrl: (NSURL *)url;
- (void)cancelAllLoads;

@end
