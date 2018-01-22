//
//  MEKDownloadControllerTests.m
//  YouTubeListenerTests
//
//  Created by Matvey Kravtsov on 20/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>
#import "MEKDownloadController.h"

@interface MEKDownloadController(Tests)

@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, copy) NSMutableDictionary *tasks;
@property (nonatomic, copy) NSMutableDictionary *params;
@property (nonatomic, assign) BOOL backgroundMode;

- (NSURLSessionConfiguration*)createSessionConfigurationWithBackgroundMode: (BOOL) background;
- (void)removeTaskForKey: (NSString *)key;

@end
@interface MEKDownloadControllerTests : XCTestCase

@property (nonatomic, strong) MEKDownloadController *downloadController;

@end

@implementation MEKDownloadControllerTests

- (void)setUp {
    [super setUp];
    self.downloadController = OCMPartialMock([MEKDownloadController new]);
}

- (void)tearDown {
    self.downloadController = nil;
    [super tearDown];
}

- (void)testCreateConfiguration
{
    NSURLSessionConfiguration *configuration = [self.downloadController createSessionConfigurationWithBackgroundMode:NO];
    
    expect(self.downloadController.backgroundMode).to.equal(NO);
    expect(configuration).notTo.beNil();
    expect(configuration.identifier).to.equal([NSURLSessionConfiguration defaultSessionConfiguration].identifier);
}

- (void)testCreateConfigurationBackground
{
    NSURLSessionConfiguration *configuration = [self.downloadController createSessionConfigurationWithBackgroundMode:YES];
    
    expect(self.downloadController.backgroundMode).to.equal(YES);
    expect(configuration).notTo.beNil();
    
    NSString *sessionIdentifier = [NSString stringWithFormat:@"%@.background", NSBundle.mainBundle.bundleIdentifier];
    expect(configuration.identifier).to.equal(sessionIdentifier);
}

- (void)testConfiguration
{
    OCMStub([self.downloadController configurateUrlSessionWithParams:nil backgroundMode:NO]);
    [self.downloadController configurateUrlSessionWithBackgroundMode:NO];
    OCMVerify([self.downloadController configurateUrlSessionWithParams:nil backgroundMode:NO]);
    
    OCMStub([self.downloadController configurateUrlSessionWithParams:nil backgroundMode:YES]);
    [self.downloadController configurateUrlSessionWithBackgroundMode:YES];
    OCMVerify([self.downloadController configurateUrlSessionWithParams:nil backgroundMode:YES]);
}

- (void)testConfigurationParams
{
    OCMStub([self.downloadController createSessionConfigurationWithBackgroundMode:NO]).andReturn([NSURLSessionConfiguration defaultSessionConfiguration]);
    
    [self.downloadController configurateUrlSessionWithParams:nil backgroundMode:NO];
    
    OCMVerify([self.downloadController createSessionConfigurationWithBackgroundMode:NO]);
    
    expect(self.downloadController.urlSession).notTo.beNil();
    expect(self.downloadController.urlSession.configuration.allowsCellularAccess).to.beTruthy();
    expect(self.downloadController.urlSession.configuration.HTTPAdditionalHeaders).to.equal(@{@"Accept" : @"application/json"});
}

- (void)testConfigurationParamsCustom
{
    OCMStub([self.downloadController createSessionConfigurationWithBackgroundMode:NO]).andReturn([NSURLSessionConfiguration defaultSessionConfiguration]);
    
    [self.downloadController configurateUrlSessionWithParams:@{} backgroundMode:NO];
    
    OCMVerify([self.downloadController createSessionConfigurationWithBackgroundMode:NO]);
    
    expect(self.downloadController.urlSession).notTo.beNil();
    expect(self.downloadController.urlSession.configuration.allowsCellularAccess).to.beTruthy();
    expect(self.downloadController.urlSession.configuration.HTTPAdditionalHeaders).to.equal(@{});
}

- (void)testDownloadDataFromURL
{
    NSString *key = @"key";
    NSDictionary *params = @{@"test" : @"test"};
    NSURL *url = [NSURL URLWithString:@"https://google.com"];
    
    NSURLSession *urlSession = OCMClassMock([NSURLSession class]);
    
    NSURLSessionDownloadTask *expectedTask = OCMClassMock([NSURLSessionDownloadTask class]);
    OCMStub([urlSession downloadTaskWithURL:url]).andReturn(expectedTask);
    
    OCMStub(self.downloadController.urlSession).andReturn(urlSession);

    [self.downloadController downloadDataFromURL:url forKey:key withParams:params];
    
    OCMVerify([expectedTask setTaskDescription:key]);
    OCMVerify([expectedTask resume]);
    
    NSURLSessionDownloadTask *task = self.downloadController.tasks[key];
    expect(task).notTo.beNil();
    expect(task).to.equal(expectedTask);
    
    expect(self.downloadController.params[key]).to.equal(params);
}

- (void)testDownloadDataFromURLNil
{
    NSString *key = @"key";
    NSDictionary *params = @{@"test" : @"test"};

    NSURLSession *urlSession = OCMClassMock([NSURLSession class]);
    OCMStub(self.downloadController.urlSession).andReturn(urlSession);
    
    OCMReject([urlSession downloadTaskWithURL:OCMOCK_ANY]);
    
    [self.downloadController downloadDataFromURL:nil forKey:key withParams:params];
    

    expect(self.downloadController.tasks[key]).to.beNil();
    expect(self.downloadController.params[key]).to.beNil();
}

- (void)testCancelDownload
{
    NSString *key = @"key";
    
    NSURLSessionDownloadTask *task = OCMClassMock([NSURLSessionDownloadTask class]);
    OCMStub(self.downloadController.tasks).andReturn(@{key : task}.mutableCopy);

    OCMStub([self.downloadController removeTaskForKey:key]);
    
    [self.downloadController cancelDownloadForKey:key];
    
    OCMVerify([task cancel]);
    OCMVerify([self.downloadController removeTaskForKey:key]);
}

- (void)testCancelDownloadNil
{
    NSString *key = @"key";
    
    OCMReject([self.downloadController removeTaskForKey:key]);
    
    [self.downloadController cancelDownloadForKey:key];
}

- (void)testGetProcess
{
    NSString *key = @"key";
    
    NSURLSessionDownloadTask *task = OCMClassMock([NSURLSessionDownloadTask class]);
    OCMStub(self.downloadController.tasks).andReturn(@{key : task}.mutableCopy);
    
    OCMStub(task.countOfBytesReceived).andReturn(1);
    OCMStub(task.countOfBytesExpectedToReceive).andReturn(1);
    
    double progress = [self.downloadController getProgressForKey:key];
    
    expect(progress).to.equal(1);
}

- (void)testGetProcessNil
{
    double progress = [self.downloadController getProgressForKey:nil];
    
    expect(progress).to.equal(0);
}

- (void)testRemoveTask
{
    NSString *key = @"key";
    
    NSURLSessionDownloadTask *task = OCMClassMock([NSURLSessionDownloadTask class]);
    OCMStub(self.downloadController.tasks).andReturn(@{key : task}.mutableCopy);
    OCMStub(self.downloadController.params).andReturn(@{key : @{}}.mutableCopy);
    
    [self.downloadController removeTaskForKey:key];
    
    expect(self.downloadController.tasks[key]).to.beNil();
    expect(self.downloadController.params[key]).to.beNil();
}

- (void)testRemoveTaskNotExisting
{
    NSString *key = @"key";
    
    [self.downloadController removeTaskForKey:key];
    
    expect(self.downloadController.tasks[key]).to.beNil();
    expect(self.downloadController.params[key]).to.beNil();
}

- (void)testHasTask
{
    NSString *key = @"key";
    
    BOOL hasTask = [self.downloadController hasTaskForKey:key];
    expect(hasTask).to.beFalsy();
    
    NSURLSessionDownloadTask *task = OCMClassMock([NSURLSessionDownloadTask class]);
    OCMStub(self.downloadController.tasks).andReturn(@{key : task}.mutableCopy);
    
    hasTask = [self.downloadController hasTaskForKey:key];
    
    expect(hasTask).to.beTruthy();
}

- (void)testDownloadTaskProgress
{
    id<MEKDownloadControllerDelegate> delegate = OCMProtocolMock(@protocol(MEKDownloadControllerDelegate));
    self.downloadController.delegate = delegate;
    
    OCMStub([delegate respondsToSelector:@selector(downloadControllerProgress:forKey:withParams:)]).andReturn(YES);
    
    
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    NSURLSessionDownloadTask *task = OCMClassMock([NSURLSessionDownloadTask class]);
    
    NSString *key = @"key";
    OCMStub(task.taskDescription).andReturn(key);
    OCMStub([self.downloadController getProgressForKey:key]).andReturn(1);
    
    NSDictionary *params = @{};
    self.downloadController.params = @{key : params}.mutableCopy;


    [self.downloadController URLSession:session downloadTask:task didWriteData:1 totalBytesWritten:1 totalBytesExpectedToWrite:1];
    
    OCMVerify([self.downloadController getProgressForKey:key]);
    OCMVerify([delegate downloadControllerProgress:1 forKey:key withParams:params]);
}

- (void)testDownloadComplete
{
    id<MEKDownloadControllerDelegate> delegate = OCMProtocolMock(@protocol(MEKDownloadControllerDelegate));
    self.downloadController.delegate = delegate;
    
    OCMStub([delegate respondsToSelector:@selector(downloadControllerDidFinishWithTempUrl:forKey:withParams:)]).andReturn(YES);
    
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    NSURLSessionDownloadTask *task = OCMClassMock([NSURLSessionDownloadTask class]);
    
    NSString *key = @"key";
    OCMStub(task.taskDescription).andReturn(key);
    OCMStub([self.downloadController removeTaskForKey:key]);
    
    NSDictionary *params = @{};
    self.downloadController.params = @{key : params}.mutableCopy;
    
    NSURL *url = [NSURL URLWithString:@"https://google.com"];
    
    [self.downloadController URLSession:session downloadTask:task didFinishDownloadingToURL:url];
    
    OCMVerify([self.downloadController removeTaskForKey:key]);
    OCMVerify([delegate downloadControllerDidFinishWithTempUrl:url forKey:key withParams:params]);
}

- (void)testDownloadCompleteWithError
{
    id<MEKDownloadControllerDelegate> delegate = OCMProtocolMock(@protocol(MEKDownloadControllerDelegate));
    self.downloadController.delegate = delegate;
    
    OCMStub([delegate respondsToSelector:@selector(downloadControllerDidFinishWithError:forKey:withParams:)]).andReturn(YES);
    
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    NSURLSessionDownloadTask *task = OCMClassMock([NSURLSessionDownloadTask class]);
    
    NSString *key = @"key";
    OCMStub(task.taskDescription).andReturn(key);
    OCMStub([self.downloadController removeTaskForKey:key]);
    
    NSDictionary *params = @{};
    self.downloadController.params = @{key : params}.mutableCopy;
    
    NSError *error = OCMClassMock([NSError class]);
    
    [self.downloadController URLSession:session task:task didCompleteWithError:error];
    
    OCMVerify([self.downloadController removeTaskForKey:key]);
    OCMVerify([delegate downloadControllerDidFinishWithError:error forKey:key withParams:params]);
}

@end
