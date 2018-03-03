//
//  UIImage+Cache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEKImageDownloadController;

@interface UIImage(Cache)

+ (void)ch_downloadImageFromUrl: (NSURL*) url completion:(void (^)(UIImage *image, BOOL fromCache))completion;

@end
