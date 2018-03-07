//
//  UIImage+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImage+Cache.h"
#import "MEKImageLoader.h"

@implementation UIImage(Cache)

#pragma mark - Public Static

+ (void)ch_downloadImageFromUrl:(NSURL *)url completion:(ImageLoaderCompletionBlock)completion
{
    if (!url)
    {
        return;
    }

    [[MEKImageLoader sharedInstance] loadImageFromUrl:url completion:completion];
}

@end
