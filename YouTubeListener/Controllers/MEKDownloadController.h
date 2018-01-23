//
//  MEKDownloadController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MEKDownloadControllerDelegate <NSObject>

@optional
- (void)downloadControllerProgress: (double) progress forKey: (NSString*) key withParams: (NSDictionary*) params;
- (void)downloadControllerDidFinishWithTempUrl: (NSURL*) url forKey:(NSString *) key withParams: (NSDictionary*) params;
- (void)downloadControllerDidFinishWithError: (NSError*) error forKey:(NSString *) key withParams: (NSDictionary*) params;

@end

@interface MEKDownloadController : NSObject

@property (nonatomic, weak) id<MEKDownloadControllerDelegate> delegate;
@property (nonatomic, readonly) BOOL backgroundMode;

- (void)configurateUrlSessionWithBackgroundMode: (BOOL) background;
- (void)configurateUrlSessionWithParams:(NSDictionary *)params backgroundMode: (BOOL) background;
- (void)downloadDataFromURL: (NSURL*) url forKey: (NSString*) key withParams: (NSDictionary*) params;
- (void)cancelDownloadForKey: (NSString*) key;
- (double)getProgressForKey: (NSString*) key;
- (BOOL)hasTaskForKey: (NSString*) key;

@end
