//
//  UIImageView+Cache.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView(Cache)

- (void)ch_downloadImageFromUrl: (NSURL*) url;
- (void)ch_downloadImageFromUrl: (NSURL*) url usingPlaceholder: (UIImage *)placeholder;

@end
