//
//  MEKInfoViewTests.m
//  YouTubeListenerTests
//
//  Created by Matvey Kravtsov on 20/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>
#import "MEKInfoView.h"

@interface MEKInfoViewTests : XCTestCase

@property (nonatomic, strong) MEKInfoView *infoView;

@end

@implementation MEKInfoViewTests

- (void)setUp {
    [super setUp];
    self.infoView = OCMPartialMock([MEKInfoView new]);
}

- (void)tearDown {
    self.infoView = nil;
    [super tearDown];
}

- (void)testUpdateConstraints
{
    [self.infoView setNeedsUpdateConstraints];
}

@end
