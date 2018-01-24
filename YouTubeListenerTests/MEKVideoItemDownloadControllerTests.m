//
//  MEKVideoItemDownloadControllerTests.m
//  YouTubeListenerTests
//
//  Created by Matvey Kravtsov on 24/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import "MEKVideoItemDownloadController.h"

@interface MEKVideoItemDownloadController(Tests) <MEKDownloadControllerDelegate>

@property (nonatomic, strong) MEKDownloadController *downloadController;
@property (nonatomic, strong) NSMutableDictionary *items;

@end

@interface MEKVideoItemDownloadControllerTests : XCTestCase

@property (nonatomic, strong) MEKVideoItemDownloadController *itemDownloadController;

@end

@implementation MEKVideoItemDownloadControllerTests

- (void)setUp {
    [super setUp];
    
    MEKDownloadController *downloadController = OCMClassMock([MEKDownloadController class]);
    self.itemDownloadController = OCMPartialMock([[MEKVideoItemDownloadController alloc] initWithDownloadController:downloadController]);
}

- (void)tearDown {
    self.itemDownloadController = nil;
    
    [super tearDown];
}

- (void)testDownloadVideoItem
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    VideoItemQuality quality = VideoItemQualityMedium360;
    
    OCMStub(item.videoId).andReturn(@"id");
    OCMStub([self.itemDownloadController.items setObject:item forKey:item.videoId]);
    OCMExpect([self.itemDownloadController.downloadController downloadDataFromURL:OCMOCK_ANY forKey:item.videoId withParams:OCMOCK_ANY]);
    
    [self.itemDownloadController downloadVideoItem:item withQuality:quality];
    
    OCMVerify([self.itemDownloadController.items setObject:item forKey:item.videoId]);
    OCMVerifyAll((id)self.itemDownloadController.downloadController);
    
    //----------------
    OCMReject([self.itemDownloadController.items setObject:OCMOCK_ANY forKey:OCMOCK_ANY]);
    OCMReject([self.itemDownloadController.downloadController downloadDataFromURL:OCMOCK_ANY forKey:OCMOCK_ANY withParams:OCMOCK_ANY]);
    [self.itemDownloadController downloadVideoItem:nil withQuality:quality];
}

- (void)testDownloadingVideoItem
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    MEKDownloadController *downloadController = self.itemDownloadController.downloadController;
    
    OCMExpect([downloadController hasTaskForKey:OCMOCK_ANY]).andReturn(YES);
    
    BOOL isOK = [self.itemDownloadController downloadingVideoItem:item];
    
    expect(isOK).to.beTruthy();
    
    //------------
    OCMExpect([downloadController hasTaskForKey:OCMOCK_ANY]).andReturn(NO);
    
    isOK = [self.itemDownloadController downloadingVideoItem:item];
    
    expect(isOK).to.beFalsy();
}

- (void)testGetProgressForVideoItem
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    MEKDownloadController *downloadController = self.itemDownloadController.downloadController;
    
    OCMExpect([downloadController getProgressForKey:OCMOCK_ANY]).andReturn(0.5);
    
    double progress = [self.itemDownloadController getProgressForVideoItem:item];
    
    expect(progress).to.equal(0.5);
}

- (void)testCancelDownloadingVideoItem
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    MEKDownloadController *downloadController = self.itemDownloadController.downloadController;
    
    OCMExpect([downloadController cancelDownloadForKey:OCMOCK_ANY]);
    
    [self.itemDownloadController cancelDownloadingVideoItem:item];
    
    OCMVerifyAll((id)downloadController);
}

- (void)testDownloadControllerProgress
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    NSString *key = @"key";
    double progress = 0.5;
    self.itemDownloadController.items = @{key : item}.mutableCopy;
    
    id<MEKVideoItemDownloadControllerDelegate> delegate = OCMProtocolMock(@protocol(MEKVideoItemDownloadControllerDelegate));
    self.itemDownloadController.delegate = delegate;
    
    OCMExpect([delegate respondsToSelector:@selector(videoItemDownloadControllerProgress:forVideoItem:)]).andReturn(YES);
    OCMExpect([delegate videoItemDownloadControllerProgress:progress forVideoItem:item]);
    
    [self.itemDownloadController downloadControllerProgress:progress forKey:key withParams:nil];
    
    OCMVerifyAllWithDelay((id)delegate, 1);
}

- (void)testDownloadControllerDidFinishWithTempUrl
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    NSString *key = @"key";
    VideoItemQuality quality = VideoItemQualityMedium360;
    self.itemDownloadController.items = @{key : item}.mutableCopy;
    NSDictionary *params = @{@"quality" : @(quality)};
    NSURL *url = OCMClassMock([NSURL class]);
    
    OCMExpect([item saveTempPathURL:url withQuality:quality]);
    
    [self.itemDownloadController downloadControllerDidFinishWithTempUrl:url forKey:key withParams:params];
    
    OCMVerifyAll((id)item);
}

- (void)testDownloadControllerDidFinishWithError
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    NSString *key = @"key";
    self.itemDownloadController.items = @{key : item}.mutableCopy;
    NSError *error = OCMClassMock([NSError class]);
    
    id<MEKVideoItemDownloadControllerDelegate> delegate = OCMProtocolMock(@protocol(MEKVideoItemDownloadControllerDelegate));
    self.itemDownloadController.delegate = delegate;
    
    OCMExpect([delegate respondsToSelector:@selector(videoItemDownloadControllerDidFinishWithError:forVideoItem:)]).andReturn(YES);
    OCMExpect([delegate videoItemDownloadControllerDidFinishWithError:error forVideoItem:item]);
    
    [self.itemDownloadController downloadControllerDidFinishWithError:error forKey:key withParams:nil];
    
    expect(self.itemDownloadController.items[key]).to.beNil();
    OCMVerifyAllWithDelay((id)delegate, 1);
}

@end
