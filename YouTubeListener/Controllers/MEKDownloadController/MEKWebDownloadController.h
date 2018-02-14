//
//  MEKWebDownloadController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MEKDownloadControllerProtocol.h"

@protocol MEKWebDownloadControllerDelegate <MEKDownloadControllerOutputProtocol>

@end

@interface MEKWebDownloadController : NSObject <MEKDownloadControllerInputProtocol>

@property (nonatomic, weak) id<MEKWebDownloadControllerDelegate> delegate;

@end
