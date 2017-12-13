//
//  NetworkService.h
//  URLtest
//
//  Created by Matvey Kravtsov on 30/11/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkServiceProtocol.h"

@interface NetworkService : NSObject<NetworkServiceInputProtocol, NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, weak) id<NetworkServiceOutputProtocol> output;

@end
