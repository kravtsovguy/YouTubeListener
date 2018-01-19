//
//  MEKProgressBarTests.m
//  YouTubeListenerTests
//
//  Created by Matvey Kravtsov on 19/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>
#import "MEKProgressBar.h"

@interface MEKProgressBarTests : XCTestCase

@property (nonatomic, strong) MEKProgressBar *progressBar;

@end

@implementation MEKProgressBarTests

- (void)setUp
{
    [super setUp];
    
    self.progressBar = OCMPartialMock([MEKProgressBar new]);
}

- (void)tearDown
{
    self.progressBar = nil;
    
    [super tearDown];
}

- (void)testExample
{
    
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
