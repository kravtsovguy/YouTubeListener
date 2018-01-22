//
//  MEKDownloadController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKDownloadController.h"

@interface MEKDownloadController ()

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, copy) NSMutableDictionary *tasks;
@property (nonatomic, copy) NSMutableDictionary *params;
@property (nonatomic, assign) BOOL backgroundMode;

@end

@implementation MEKDownloadController

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _tasks = [NSMutableDictionary new];
        _params = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Public

- (void)configurateUrlSessionWithBackgroundMode:(BOOL)background
{
    [self configurateUrlSessionWithParams:nil backgroundMode:background];
}

- (void)configurateUrlSessionWithParams:(NSDictionary *)params backgroundMode: (BOOL) background
{
    NSURLSessionConfiguration *sessionConfiguration = [self createSessionConfigurationWithBackgroundMode:background];
    sessionConfiguration.allowsCellularAccess = YES;
    
    if (params)
    {
        sessionConfiguration.HTTPAdditionalHeaders = params;
    }
    else
    {
        sessionConfiguration.HTTPAdditionalHeaders = @{@"Accept" : @"application/json"};
    }
    
    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[NSOperationQueue new]];
}

- (void)downloadDataFromURL:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    if (!url || [self hasTaskForKey:key])
    {
        return;
    }
    
    NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithURL:url];
    task.taskDescription = key;
    self.tasks[key] = task;
    self.params[key] = params;
    
    [task resume];
}

- (void)cancelDownloadForKey:(NSString *)key
{
    NSURLSessionDownloadTask *task = self.tasks[key];
    if (!task)
    {
        return;
    }
    
    [task cancel];
    [self removeTaskForKey:key];
}

- (double)getProgressForKey:(NSString *)key
{
    NSURLSessionDownloadTask *task = self.tasks[key];
    if (!task || task.countOfBytesExpectedToReceive == 0)
    {
        return 0;
    }
    
    double progress = (double)task.countOfBytesReceived/(double)task.countOfBytesExpectedToReceive;
    return progress;
}

- (BOOL)hasTaskForKey:(NSString *)key
{
    return self.tasks[key] != nil;
}

#pragma mark - Private

- (NSURLSessionConfiguration*)createSessionConfigurationWithBackgroundMode: (BOOL) background
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
    
    return sessionConfiguration;
}

- (void)removeTaskForKey: (NSString *)key
{
    [self.tasks removeObjectForKey:key];
    [self.params removeObjectForKey:key];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSString *key = downloadTask.taskDescription;
    NSDictionary *params = self.params[key];
    
    double progress = [self getProgressForKey:key];
    
    if ([self.delegate respondsToSelector:@selector(downloadControllerProgress:forKey:withParams:)])
    {
        [self.delegate downloadControllerProgress:progress forKey:key withParams:params];
    }
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location
{
    NSString *key = downloadTask.taskDescription;
    NSDictionary *params = self.params[key];
    [self removeTaskForKey:key];
    
    if ([self.delegate respondsToSelector:@selector(downloadControllerDidFinishWithTempUrl:forKey:withParams:)])
    {
        [self.delegate downloadControllerDidFinishWithTempUrl:location forKey:key withParams:params];
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSString *key = task.taskDescription;
    NSDictionary *params = self.params[key];
    [self removeTaskForKey:key];
    
    if ([self.delegate respondsToSelector:@selector(downloadControllerDidFinishWithError:forKey:withParams:)])
    {
        [self.delegate downloadControllerDidFinishWithError:error forKey:key withParams:params];
    }
}

@end
