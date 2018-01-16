//
//  MEKDownloadController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDownloadController.h"

@interface MEKDownloadController () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, copy) NSMutableDictionary *keys;
@property (nonatomic, assign) BOOL backgroundMode;

@end

@implementation MEKDownloadController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keys = [NSMutableDictionary new];
    }
    return self;
}

-(void)configurateUrlSessionWithParams:(NSDictionary *)params backgroundMode: (BOOL) background
{
    
    self.backgroundMode = background;
    
    NSURLSessionConfiguration *sessionConfiguration;
    if (background)
    {
        NSString *sessionIdentifier = [NSString stringWithFormat:@"%@.background", NSBundle.mainBundle.bundleIdentifier];
        
        sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:sessionIdentifier];
    }
    else
    {
        sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    [sessionConfiguration setAllowsCellularAccess:YES];
    
    if (params)
    {
        [sessionConfiguration setHTTPAdditionalHeaders:params];
    }
    else
    {
        [sessionConfiguration setHTTPAdditionalHeaders:@{@"Accept" : @"application/json"}];
    }
    
    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue new]];
}

- (void)downloadDataFromURL:(NSURL *)url forKey:(NSString *)key
{
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithURL:url];
    task.taskDescription = key;
    self.keys[key] = task;
    [task resume];
}

- (void)cancelDownloadForKey:(NSString *)key
{
    NSURLSessionDownloadTask *task = self.keys[key];
    [task cancel];
    
    [self.keys removeObjectForKey:key];
}

- (double)getProgressForKey:(NSString *)key
{
    NSURLSessionDownloadTask *task = self.keys[key];
    if (!task)
        return 0;
    
    double progress = (double)task.countOfBytesReceived/(double)task.countOfBytesExpectedToReceive;
    
    return progress;
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location
{
    if ([self.delegate respondsToSelector:@selector(downloadControllerDidFinishWithTempUrl:forKey:)])
    {
        [self.delegate downloadControllerDidFinishWithTempUrl:location forKey:downloadTask.taskDescription];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(downloadControllerDidFinishWithError:forKey:)])
    {
        [self.delegate downloadControllerDidFinishWithError:error forKey:task.taskDescription];
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == 0)
    {
        return;
    }
    
    double progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
    NSLog(@"progress: %f", progress);
    
    if ([self.delegate respondsToSelector:@selector(downloadControllerProgress:forKey:)])
    {
        [self.delegate downloadControllerProgress:progress forKey:downloadTask.taskDescription];
    }
}

@end
