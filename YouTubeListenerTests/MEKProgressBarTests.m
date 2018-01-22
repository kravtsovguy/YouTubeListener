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

@interface MEKProgressBar (Tests)

@property (nonatomic, assign) CGFloat progressBarWidth;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *backProgressLayer;

@end

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

- (void)testGetProgress
{
    self.progressBar.progress = 0.5;
    
    expect(self.progressBar.progress).to.equal(0.5);
}

- (void)testSetProgressLessThanZero
{
    self.progressBar.progress = -0.5;
    
    expect(self.progressBar.progress).to.equal(0);
}

- (void)testSetProgressMoreThanOne
{
    self.progressBar.progress = 1.1;
    
    expect(self.progressBar.progress).to.equal(1);
}

- (void)testSetRadius
{
    self.progressBar.progressBarWidth = 1;
    
    expect(self.progressBar.progressLayer.lineWidth).to.equal(1);
    expect(self.progressBar.backProgressLayer.lineWidth).to.equal(1);
}

- (void)testLayoutSubviews
{
    [self.progressBar layoutIfNeeded];
    
    CGFloat radius = CGRectGetHeight(self.progressBar.frame) * 0.1;
    expect(self.progressBar.progressBarWidth).to.equal(radius);
}

@end
