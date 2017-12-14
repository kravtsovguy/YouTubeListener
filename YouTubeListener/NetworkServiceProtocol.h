//
//  NetworkserviceProtocol.h
//  URLtest
//
//  Created by Matvey Kravtsov on 30/11/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkServiceInputProtocol <NSObject>
@optional

- (void)configurateUrlSessionWithParams: (NSDictionary *)params;
- (NSURLSessionDownloadTask*)loadDataFromURL: (NSURL*) url;

@end

@protocol NetworkServiceOutputProtocol <NSObject>

@optional

-(void)loadingContinuesWithProgress: (double) progress withTask:(NSURLSessionDownloadTask*) task withService: (id<NetworkServiceInputProtocol>) service;
-(void)loadingIsDoneWithDataRecieved: (NSData *) dataRecieved withTask:(NSURLSessionDownloadTask*) task withService: (id<NetworkServiceInputProtocol>) service;

@end
