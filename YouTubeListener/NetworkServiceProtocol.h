//
//  NetworkserviceProtocol.h
//  URLtest
//
//  Created by Matvey Kravtsov on 30/11/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkServiceOutputProtocol <NSObject>

@optional

-(void)loadingContinuesWithProgress: (double) progress;
-(void)loadingIsDoneWithDataRecieved: (NSData *) dataRecieved;

@end

@protocol NetworkServiceInputProtocol <NSObject>
@optional

- (void)configurateUrlSessionWithParams: (NSDictionary *)params;
- (void)startImageLoading;
- (void)testYoutube;

@end
