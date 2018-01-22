//
//  MEKDowloadButtonTests.m
//  YouTubeListenerTests
//
//  Created by Matvey Kravtsov on 20/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import "MEKDowloadButton.h"

@interface MEKDowloadButton(Tests)

@property (nonatomic, strong) MEKProgressBar *progressBar;
@property (nonatomic, strong) UIView *stopView;
@property (nonatomic, strong) UIImage *downloadImage;
@property (nonatomic, strong) UIImage *doneImage;

@end

@interface MEKDowloadButtonTests : XCTestCase

@property (nonatomic, strong) MEKDowloadButton *downloadButton;

@end

@implementation MEKDowloadButtonTests

- (void)setUp
{
    [super setUp];
    
    self.downloadButton = OCMPartialMock([MEKDowloadButton new]);
}

- (void)tearDown
{
    self.downloadButton = nil;
    
    [super tearDown];
}

- (void)testSetProgress
{
    self.downloadButton.progress = 0;
    expect(self.downloadButton.progress).to.equal(0);
    expect(self.downloadButton.isLoading).to.equal(NO);
    expect(self.downloadButton.isDone).to.equal(NO);
    expect(self.downloadButton.progressBar.hidden).to.equal(YES);
    expect(self.downloadButton.stopView.hidden).to.equal(YES);
    expect(self.downloadButton.userInteractionEnabled).to.equal(YES);
    expect(self.downloadButton.currentImage).to.equal(self.downloadButton.downloadImage);
    
    self.downloadButton.progress = 0.5;
    expect(self.downloadButton.progress).to.equal(0.5);
    expect(self.downloadButton.isLoading).to.equal(YES);
    expect(self.downloadButton.isDone).to.equal(NO);
    expect(self.downloadButton.progressBar.hidden).to.equal(NO);
    expect(self.downloadButton.stopView.hidden).to.equal(NO);
    expect(self.downloadButton.userInteractionEnabled).to.equal(YES);
    expect(self.downloadButton.currentImage).to.beNil();
    
    self.downloadButton.progress = 1;
    expect(self.downloadButton.progress).to.equal(0);
    expect(self.downloadButton.isLoading).to.equal(NO);
    expect(self.downloadButton.isDone).to.equal(YES);
    expect(self.downloadButton.progressBar.hidden).to.equal(YES);
    expect(self.downloadButton.stopView.hidden).to.equal(YES);
    expect(self.downloadButton.userInteractionEnabled).to.equal(NO);
    expect(self.downloadButton.currentImage).to.equal(self.downloadButton.doneImage);
    
}

- (void)testLayoutSubviews
{
    [self.downloadButton layoutSubviews];
    
    expect(self.downloadButton.progressBar.frame).to.equal(self.downloadButton.bounds);
    
    CGFloat stopViewSize = CGRectGetHeight(self.downloadButton.frame) / 3;
    CGRect frame = CGRectMake((CGRectGetWidth(self.downloadButton.frame) - stopViewSize)/ 2, (CGRectGetHeight(self.downloadButton.frame) - stopViewSize)/ 2, stopViewSize, stopViewSize);
    
    expect(self.downloadButton.stopView.frame).to.equal(frame);
    expect(self.downloadButton.stopView.layer.cornerRadius).to.equal(stopViewSize / 4);
}

@end
