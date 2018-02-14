//
//  MEKDownloadControllerProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#ifndef MEKDownloadControllerProtocol_h
#define MEKDownloadControllerProtocol_h

#import <Foundation/Foundation.h>

@protocol MEKDownloadControllerInputProtocol <NSObject>

@required
- (void)downloadDataFromURL: (NSURL*) url forKey: (NSString*) key withParams: (NSDictionary*) params;
- (void)downloadDataFromRequest: (NSURLRequest*) request forKey: (NSString*) key withParams: (NSDictionary*) params;
- (void)cancelDownloadForKey: (NSString*) key;
- (BOOL)hasDownloadForKey: (NSString*) key;
- (double)getProgressForKey: (NSString*) key;

@end

@protocol MEKDownloadControllerOutputProtocol <NSObject>

@optional
- (BOOL)downloadControllerDidFinish: (id<MEKDownloadControllerInputProtocol>) downloadController withTempUrl: (NSURL*) url forKey:(NSString *) key withParams: (NSDictionary*) params;
- (void)downloadControllerDidFinish: (id<MEKDownloadControllerInputProtocol>) downloadController withError: (NSError*) error forKey:(NSString *) key withParams: (NSDictionary*) params;

@end

#endif /* MEKDownloadControllerProtocol_h */
