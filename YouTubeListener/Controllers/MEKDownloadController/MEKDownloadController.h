//
//  MEKDownloadController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEKDownloadControllerProtocol.h"

@protocol MEKDownloadControllerDelegate <MEKDownloadControllerOutputProtocol>

@optional
- (void)downloadControllerProgress: (double) progress forKey: (NSString*) key withParams: (NSDictionary*) params;

@end

@interface MEKDownloadController : NSObject <MEKDownloadControllerInputProtocol>

@property (nonatomic, weak) id<MEKDownloadControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL backgroundMode;

- (instancetype)initWithBackgroundMode: (BOOL) background;
- (void)configurateUrlSessionWithBackgroundMode: (BOOL) background;
- (void)configurateUrlSessionWithParams:(NSDictionary *)params backgroundMode: (BOOL) background;

@end
