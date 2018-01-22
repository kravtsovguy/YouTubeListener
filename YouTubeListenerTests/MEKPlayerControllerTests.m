//
//  MEKPlayerControllerTests.m
//  YouTubeListenerTests
//
//  Created by Matvey Kravtsov on 22/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Expecta/Expecta.h>

#import "MEKPlayerController.h"

@interface MEKPlayerController(Tests) <UIScrollViewDelegate, MEKVideoPlayerViewControllerDelegate>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) MEKVideoPlayerViewController *playerViewController;

@property (nonatomic, readonly) UITabBarController *tabBarController;
@property (nonatomic, readonly) UIView *tabBarMainView;
@property (nonatomic, readonly) CGRect mainFrame;

- (void)maximizePlayer;
- (void)minimizePlayer;
- (void)closePlayer;

- (void)initOverlayView;
- (void)initScrollView;
- (void)initPlayerViewControllerWithVideoItem:(VideoItemMO*) item withVisibleState:(MEKPlayerVisibleState) state;

@end

@interface MEKPlayerControllerTests : XCTestCase

@property (nonatomic, strong) MEKPlayerController *playerController;

@end

@implementation MEKPlayerControllerTests

- (void)setUp {
    [super setUp];
    self.playerController = OCMPartialMock([MEKPlayerController new]);
}

- (void)tearDown {
    self.playerController = nil;
    [super tearDown];
}

- (void)testOpenVideoItem
{
    OCMStub(self.playerController.isOpened).andReturn(YES);
    
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    
    MEKPlayerVisibleState state = MEKPlayerVisibleStateNone;
    
    state = MEKPlayerVisibleStateMinimized;
    OCMExpect([self.playerController closePlayer]);
    OCMExpect([self.playerController initOverlayView]);
    OCMExpect([self.playerController initScrollView]);
    OCMExpect([self.playerController initPlayerViewControllerWithVideoItem:item withVisibleState:state]);
    OCMExpect([self.playerController minimizePlayer]);
    
    [self.playerController openVideoItem:item withVisibleState:state];
    
    OCMVerifyAll((id)self.playerController);

    
    state = MEKPlayerVisibleStateMaximized;
    OCMExpect([self.playerController closePlayer]);
    OCMExpect([self.playerController initOverlayView]);
    OCMExpect([self.playerController initScrollView]);
    OCMExpect([self.playerController initPlayerViewControllerWithVideoItem:item withVisibleState:state]);
    OCMExpect([self.playerController maximizePlayer]);
    
    [self.playerController openVideoItem:item withVisibleState:state];
    
    OCMVerifyAll((id)self.playerController);
}

@end
