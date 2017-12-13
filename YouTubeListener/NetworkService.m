//
//  NetworkService.m
//  URLtest
//
//  Created by Matvey Kravtsov on 30/11/2017.
//  Copyright © 2017 Matvey Kravtsov. All rights reserved.
//

#import "NetworkService.h"

@interface NetworkService ()

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumeData;

@end

@implementation NetworkService

-(void)configurateUrlSessionWithParams:(NSDictionary *)params
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    if (params)
    {
        [sessionConfiguration setHTTPAdditionalHeaders:params];
    }
    else
    {
        [sessionConfiguration setHTTPAdditionalHeaders:@{@"Accept" : @"application/json"}];
    }
    
    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
}

-(void)startImageLoading
{
    if (!self.urlSession)
    {
        [self configurateUrlSessionWithParams:nil];
    }
    
    self.downloadTask = [self.urlSession downloadTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://i.ytimg.com/vi/%@/default.jpg", @"4BltTurluAg"]]];
    
    [self.downloadTask resume];
}

-(void)testYoutube
{
    if (!self.urlSession)
    {
        [self configurateUrlSessionWithParams:nil];
    }
    
    self.downloadTask = [self.urlSession downloadTaskWithURL:[NSURL URLWithString:@"https://www.youtube.com/watch?v=4BltTurluAg"]];
    
    [self.downloadTask resume];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.output)
            [self.output loadingIsDoneWithDataRecieved:data];
        
    });
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    float progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.output)
            [self.output loadingContinuesWithProgress:progress];
        
    });
}

@end
