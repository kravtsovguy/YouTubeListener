//
//  MEKDownloadControllerProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 07/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEKVideoItemDownloadController;

@protocol MEKPropertyDownloadControllerProtocol

@property (nonatomic, strong, readonly) MEKVideoItemDownloadController *downloadController;

@end
