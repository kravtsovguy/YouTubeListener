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
#import "MEKWebVideoLoader.h"
#import "AppDelegate.h"

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

- (void)minimizePlayerUI;
- (void)maximizePlayerUI;
- (void)fixContentInScrollView: (UIScrollView*) scrollView AtOffset: (CGPoint) offset;
- (void)topViewWillAppear;
- (void)playerViewWillAppear;

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

- (void)testOpenVideoItemWithVisibleState
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

- (void)testOpenVideoItem
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    
    OCMStub([self.playerController openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized]);
    
    [self.playerController openVideoItem:item];
    
    OCMVerify([self.playerController openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized]);
}

- (void)testOpenURLWithVisibleState
{
    NSURL *url = OCMClassMock([NSURL class]);
    MEKPlayerVisibleState state = MEKPlayerVisibleStateMinimized;
    
    id context = OCMClassMock([NSManagedObjectContext class]);
    id videoParser = OCMProtocolMock(@protocol(MEKWebVideoParserProtocol));
    id videoLoader = OCMClassMock([MEKWebVideoLoader class]);
    id item = OCMClassMock([VideoItemMO class]);

    OCMExpect(ClassMethod([videoLoader parserForURL:url])).andReturn(videoParser);
    
    OCMExpect(self.playerController.coreDataContext).andReturn(context);
    OCMExpect(ClassMethod([item videoItemForURL:url withContext:context])).andReturn(item);
    
    OCMExpect([self.playerController openVideoItem:item withVisibleState:state]);

    BOOL isOK = [self.playerController openURL:url withVisibleState:state];

    expect(isOK).to.beTruthy();
    OCMVerifyAll(videoLoader);
    OCMVerifyAll(item);
    OCMVerifyAll((id)self.playerController);
    
    //--------------
    OCMExpect(ClassMethod([videoLoader parserForURL:url])).andReturn(videoParser);
    
    OCMExpect(self.playerController.coreDataContext).andReturn(context);
    OCMExpect(ClassMethod([item videoItemForURL:url withContext:OCMOCK_ANY])).andReturn(nil);
    
    OCMExpect(self.playerController.coreDataContext).andReturn(context);
    OCMExpect(ClassMethod([item connectedEntityWithContext:context])).andReturn(item);
    
    OCMExpect([self.playerController openVideoItem:item withVisibleState:state]);
    
    isOK = [self.playerController openURL:url withVisibleState:state];
    
    expect(isOK).to.beTruthy();
    OCMVerifyAll(videoLoader);
    OCMVerifyAll(item);
    OCMVerifyAll((id)self.playerController);
    
    //--------------
    url = nil;
    
    OCMReject([self.playerController openVideoItem:item withVisibleState:state]);
    
    isOK = [self.playerController openURL:url withVisibleState:state];
    
    expect(isOK).to.beFalsy();
    OCMVerifyAll((id)self.playerController);
}

- (void)testOpenURL
{
    NSURL *url = OCMClassMock([NSURL class]);
    
    OCMExpect([self.playerController openURL: url withVisibleState:MEKPlayerVisibleStateMinimized]).andReturn(YES);
    
    BOOL isOK = [self.playerController openURL:url];
    
    expect(isOK).to.beTruthy();
    OCMVerifyAll((id)self.playerController);
    
    //-----------
    url = nil;
    
    OCMExpect([self.playerController openURL: url withVisibleState:MEKPlayerVisibleStateMinimized]).andReturn(NO);
    
    isOK = [self.playerController openURL:url];
    
    expect(isOK).to.beFalsy();
    OCMVerifyAll((id)self.playerController);
}

- (void)testCoreDataContext
{
    UIApplication *application = OCMClassMock([UIApplication class]);
    AppDelegate *appDelegate = OCMClassMock([AppDelegate class]);
    NSPersistentContainer *container = OCMClassMock([NSPersistentContainer class]);
    id context = OCMClassMock([NSManagedObjectContext class]);
    
    OCMExpect(ClassMethod([(id)application sharedApplication])).andReturn(application);
    OCMExpect(application.delegate).andReturn(appDelegate);
    OCMExpect(appDelegate.persistentContainer).andReturn(container);
    OCMExpect(container.viewContext).andReturn(context);
    
    NSManagedObjectContext *coreDataContext = self.playerController.coreDataContext;
    
    expect(coreDataContext).to.equal(context);
    OCMVerifyAll((id)application);
    OCMVerifyAll((id)appDelegate);
    OCMVerifyAll((id)container);
}

- (void)testTabBarController
{
    UIApplication *application = OCMClassMock([UIApplication class]);
    AppDelegate *appDelegate = OCMClassMock([AppDelegate class]);
    UITabBarController *controller = OCMClassMock([UITabBarController class]);
    
    OCMExpect(ClassMethod([(id)application sharedApplication])).andReturn(application);
    OCMExpect(application.delegate).andReturn(appDelegate);
    OCMExpect(appDelegate.tabBarController).andReturn(controller);
    
    UITabBarController *tabBarController = self.playerController.tabBarController;
    
    expect(tabBarController).to.equal(controller);
    OCMVerifyAll((id)application);
    OCMVerifyAll((id)appDelegate);
}

- (void)testTabBarMainView
{
    UITabBarController *controller = OCMClassMock([UITabBarController class]);
    OCMExpect(self.playerController.tabBarController).andReturn(controller);
    
    UIView *view = OCMClassMock([UIView class]);
    OCMExpect(controller.view).andReturn(view);
    
    UIView *subview = OCMClassMock([UIView class]);
    OCMExpect(view.subviews).andReturn(@[subview]);
    
    OCMExpect(controller.view).andReturn(controller);
    
    id resultView = self.playerController.tabBarMainView;
    
    expect(resultView).to.equal(subview);
}

- (void)testMainFrame
{
    UITabBarController *controller = OCMClassMock([UITabBarController class]);
    OCMExpect(self.playerController.tabBarController).andReturn(controller);
    
    UIView *view = OCMClassMock([UIView class]);
    OCMExpect(controller.view).andReturn(view);
    
    CGRect expectedFrame = CGRectMake(0, 0, 10, 10);
    OCMExpect(view.frame).andReturn(expectedFrame);
    
    CGRect resultFrame = self.playerController.mainFrame;
    
    expect(resultFrame).to.equal(expectedFrame);
}

- (void)testIsOpened
{
    MEKVideoPlayerViewController *controller = OCMClassMock([MEKVideoPlayerViewController class]);
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    
    BOOL isOK = self.playerController.isOpened;
    expect(isOK).to.beTruthy();
    
    OCMExpect(self.playerController.playerViewController).andReturn(nil);
    isOK = self.playerController.isOpened;
    expect(isOK).to.beFalsy();
}

- (void)initForTestVisibleState
{
    CGFloat frameHeight = 600;
    OCMExpect(self.playerController.mainFrame).andReturn(CGRectMake(0, 0, 0, frameHeight));
    
    UITabBarController *controller = OCMClassMock([UITabBarController class]);
    OCMExpect(self.playerController.tabBarController).andReturn(controller);
    
    UITabBar *tabBar = OCMClassMock([UITabBar class]);
    OCMExpect(controller.tabBar).andReturn(tabBar);
    
    CGFloat tabbarHeight = 60;
    OCMExpect(tabBar.frame).andReturn(CGRectMake(0, 0, 0, tabbarHeight));
}

- (void)testVisibleState
{
    [self initForTestVisibleState];
    
    UIScrollView *scrollView = OCMClassMock([UIScrollView class]);
    OCMExpect(self.playerController.scrollView).andReturn(scrollView);
    
    CGFloat y = 0;
    OCMExpect(scrollView.frame).andReturn(CGRectMake(0, y, 0, 0));
    
    MEKPlayerVisibleState visibleState = self.playerController.visibleState;
    
    expect(visibleState).to.equal(MEKPlayerVisibleStateNone);
    
    //------------
    [self initForTestVisibleState];

    OCMExpect(self.playerController.scrollView).andReturn(scrollView);
    
    y = 600 - 60 - MEKPlayerViewHeightSizeMinimized;
    OCMExpect(scrollView.frame).andReturn(CGRectMake(0, y, 0, 0));
    
    visibleState = self.playerController.visibleState;
    
    expect(visibleState).to.equal(MEKPlayerVisibleStateMinimized);
    
    //--------------
    [self initForTestVisibleState];
    
    OCMExpect(self.playerController.scrollView).andReturn(scrollView);
    
    y = 600 - MEKPlayerViewHeightSizeMaximized;
    OCMExpect(scrollView.frame).andReturn(CGRectMake(0, y, 0, 0));
    
    visibleState = self.playerController.visibleState;
    
    expect(visibleState).to.equal(MEKPlayerVisibleStateMaximized);
}

- (void)testMinimize
{
    MEKVideoPlayerViewController *controller = OCMClassMock([MEKVideoPlayerViewController class]);
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    OCMExpect([controller minimizeWithDuration:MEKPlayerViewAnimationDuration]);
    OCMExpect([self.playerController minimizePlayer]);
    
    [self.playerController minimize];
    
    OCMVerifyAll((id)controller);
    OCMVerifyAll((id)self.playerController);
}

- (void)testMaximize
{
    MEKVideoPlayerViewController *controller = OCMClassMock([MEKVideoPlayerViewController class]);
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    OCMExpect([controller maximizeWithDuration:MEKPlayerViewAnimationDuration]);
    OCMExpect([self.playerController maximizePlayer]);
    
    [self.playerController maximize];
    
    OCMVerifyAll((id)controller);
    OCMVerifyAll((id)self.playerController);
}

- (void)testClose
{
    OCMExpect(self.playerController.isOpened).andReturn(NO);
    [self.playerController close];
    
    //------------
    OCMExpect(self.playerController.isOpened).andReturn(YES);
    OCMExpect([self.playerController minimizePlayer]);
    
    id view = OCMClassMock([UIView class]);
    OCMExpect(ClassMethod([view animateWithDuration:MEKPlayerViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:[OCMArg checkWithBlock:^BOOL(id param) {
        
        void (^passedBlock)( void ) = param;
        
        UIScrollView *scrollView = OCMClassMock([UIScrollView class]);
        self.playerController.scrollView = scrollView;
        OCMExpect([scrollView setTransform:CGAffineTransformIdentity]);
        
        passedBlock();
        
        OCMVerifyAll((id)scrollView);
        
        return YES;
    }] completion:[OCMArg checkWithBlock:^BOOL(id param) {
        
        void (^passedBlock)( BOOL finished ) = param;
        OCMExpect([self.playerController closePlayer]);
        passedBlock(YES);
        
        return YES;
    }]]));
    
    [self.playerController close];
    
    OCMVerifyAll((id)self.playerController);
    OCMVerifyAll(view);
}

- (void)testClosePlayer
{
    OCMExpect([self.playerController setPlayerViewController:nil]);
    
    [self.playerController closePlayer];
    
    OCMVerifyAll((id)self.playerController);
}

- (void)testInitPlayerViewControllerWithVideoItem
{
    VideoItemMO *item = OCMClassMock([VideoItemMO class]);
    
    MEKVideoPlayerViewController *controller = OCMClassMock([MEKVideoPlayerViewController class]);
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    
    [self.playerController initPlayerViewControllerWithVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];
    
    OCMVerifyAll((id)controller);
    
    //------------------
    OCMExpect(self.playerController.playerViewController).andReturn(nil);
    
    OCMExpect(ClassMethod([(id)controller alloc])).andReturn(controller);
    OCMExpect([controller initWithVideoItem:item]).andReturn(controller);
    
    OCMExpect([self.playerController setPlayerViewController:controller]);
    
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    OCMExpect([controller setDelegate:OCMOCK_ANY]);
    
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    OCMExpect([controller minimizeWithDuration:0]);
    
    [self.playerController initPlayerViewControllerWithVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];
    
    OCMVerifyAll((id)controller);
    
    //------------------
    OCMExpect(self.playerController.playerViewController).andReturn(nil);
    
    OCMExpect(ClassMethod([(id)controller alloc])).andReturn(controller);
    OCMExpect([controller initWithVideoItem:item]).andReturn(controller);
    
    OCMExpect([self.playerController setPlayerViewController:controller]);
    
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    OCMExpect([controller setDelegate:OCMOCK_ANY]);
    
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    OCMExpect([controller maximizeWithDuration:0]);
    
    [self.playerController initPlayerViewControllerWithVideoItem:item withVisibleState:MEKPlayerVisibleStateMaximized];
    
    OCMVerifyAll((id)controller);
}

- (void)testInitScrollView
{
    UIScrollView *scrollView = OCMClassMock([UIScrollView class]);
    OCMExpect(self.playerController.scrollView).andReturn(scrollView);
    
    [self.playerController initScrollView];
    
    OCMVerifyAll((id)self.playerController);
    
    //--------------
    OCMExpect(self.playerController.scrollView).andReturn(nil);
    OCMExpect([self.playerController setScrollView:OCMOCK_ANY]);
    
    [self.playerController initScrollView];
    
    OCMVerifyAll((id)self.playerController);
}

- (void)testInitOverlayView
{
    UIView *view = OCMClassMock([UIView class]);
    OCMExpect(self.playerController.overlayView).andReturn(view);
    
    [self.playerController initOverlayView];
    
    OCMVerifyAll((id)self.playerController);
    
    //--------------
    OCMExpect(self.playerController.overlayView).andReturn(nil);
    OCMExpect([self.playerController setOverlayView:OCMOCK_ANY]);
    
    [self.playerController initOverlayView];
    
    OCMVerifyAll((id)self.playerController);
}

- (void)testMinimizePlayerUI
{
    OCMExpect(self.playerController.overlayView).andReturn(nil);
    OCMExpect(self.playerController.tabBarController).andReturn(nil);
    OCMExpect(self.playerController.tabBarMainView).andReturn(nil);
    OCMExpect(self.playerController.scrollView).andReturn(nil);
    
    [self.playerController minimizePlayerUI];
    
    OCMVerifyAll((id)self.playerController);
}

- (void)testMaximizePlayerUI
{
    OCMExpect(self.playerController.overlayView).andReturn(nil);
    OCMExpect(self.playerController.tabBarController).andReturn(nil);
    OCMExpect(self.playerController.tabBarMainView).andReturn(nil);
    OCMExpect(self.playerController.scrollView).andReturn(nil);
    
    [self.playerController maximizePlayerUI];
    
    OCMVerifyAll((id)self.playerController);
}

- (void)testMinimizePlayer
{
    OCMExpect([self.playerController topViewWillAppear]);

    UIView *view = OCMClassMock([UIView class]);
    
    OCMStub(self.playerController.tabBarMainView).andReturn(view);
    OCMExpect([view setNeedsUpdateConstraints]);
    OCMExpect([view updateConstraintsIfNeeded]);
    
    OCMExpect(ClassMethod([(id)view animateWithDuration:MEKPlayerViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:[OCMArg checkWithBlock:^BOOL(id param) {
        
        void (^passedBlock)( void ) = param;
        OCMExpect([self.playerController minimizePlayerUI]);
        passedBlock();
        
        return YES;
    }] completion:OCMOCK_ANY]));
    
    [self.playerController minimizePlayer];
    
    OCMVerifyAll((id)self.playerController);
    OCMVerifyAll((id)view);
}

- (void)testMaximizePlayer
{
    OCMExpect([self.playerController playerViewWillAppear]);

    UIView *view = OCMClassMock([UIView class]);
    
    OCMStub(self.playerController.tabBarMainView).andReturn(view);
    OCMExpect([view setTranslatesAutoresizingMaskIntoConstraints:NO]);
    OCMExpect([view setNeedsUpdateConstraints]);
    OCMExpect([view updateConstraintsIfNeeded]);
    
    OCMExpect(ClassMethod([(id)view animateWithDuration:MEKPlayerViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:[OCMArg checkWithBlock:^BOOL(id param) {
        
        void (^passedBlock)( void ) = param;
        OCMExpect([self.playerController maximizePlayerUI]);
        passedBlock();
        
        return YES;
    }] completion:[OCMArg checkWithBlock:^BOOL(id param) {
        
        void (^passedBlock)( BOOL finished ) = param;
        OCMExpect([view setTranslatesAutoresizingMaskIntoConstraints:YES]);
        passedBlock(YES);
        
        return YES;
    }]]));
    
    [self.playerController maximizePlayer];
    
    OCMVerifyAll((id)self.playerController);
    OCMVerifyAll((id)view);
}

- (void)testFixContentInScrollView
{
    UIScrollView *scrollView = OCMClassMock([UIScrollView class]);
    CGPoint offset = CGPointMake(0, 0);
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
    
    OCMExpect([scrollView setContentOffset:offset animated:NO]);
    OCMExpect([scrollView scrollRectToVisible:rect animated:YES]);
    
    [self.playerController fixContentInScrollView:scrollView AtOffset:offset];
    
    OCMVerifyAll((id)scrollView);
}

- (void)testTopViewWillAppear
{
    UITabBarController *controller = OCMClassMock([UITabBarController class]);
    OCMExpect(self.playerController.tabBarController).andReturn(controller);
    
    UINavigationController *navController = OCMClassMock([UINavigationController class]);
    OCMExpect(controller.selectedViewController).andReturn(navController);
    
    UIViewController *viewController = OCMClassMock([UIViewController class]);
    OCMExpect(navController.topViewController).andReturn(viewController);
    OCMExpect([viewController viewWillAppear:NO]);
    
    [self.playerController topViewWillAppear];
    
    OCMVerifyAll((id)viewController);
}

- (void)testPlayerViewWillAppear
{
    MEKVideoPlayerViewController *controller = OCMClassMock([MEKVideoPlayerViewController class]);
    OCMExpect(self.playerController.playerViewController).andReturn(controller);
    
    OCMExpect([controller viewWillAppear:NO]);
    
    [self.playerController playerViewWillAppear];
    
    OCMVerifyAll((id)controller);
}

- (void)testScrollViewDidScroll
{
    UIScrollView *scrollView = OCMClassMock([UIScrollView class]);
    
    CGPoint point = CGPointMake(0, 150);
    OCMExpect(scrollView.contentOffset).andReturn(point);
    
    OCMExpect([self.playerController fixContentInScrollView:scrollView AtOffset:CGPointMake(0, 100)]);
    OCMExpect([self.playerController maximize]);
    
    [self.playerController scrollViewDidScroll:scrollView];
    
    OCMVerifyAll((id)self.playerController);
    
    //-------------
    point = CGPointMake(0, -150);
    OCMExpect(scrollView.contentOffset).andReturn(point);
    OCMExpect(scrollView.contentOffset).andReturn(point);
    
    OCMExpect([self.playerController fixContentInScrollView:scrollView AtOffset:CGPointMake(0, -80)]);
    OCMExpect([self.playerController minimize]);
    
    [self.playerController scrollViewDidScroll:scrollView];
    
    OCMVerifyAll((id)self.playerController);
}

- (void)testVideoPlayerViewControllerOpen
{
    OCMExpect([self.playerController maximize]);
    
    [self.playerController videoPlayerViewControllerOpen];
    
    OCMVerifyAll((id)self.playerController);
}

- (void)testVideoPlayerViewControllerClosed
{
    OCMExpect([self.playerController close]);
    
    [self.playerController videoPlayerViewControllerClosed];
    
    OCMVerifyAll((id)self.playerController);
}

@end
