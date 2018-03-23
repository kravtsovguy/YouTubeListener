//
//  MEKCombinedSearchResultsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 19/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCombinedSearchResultsViewController.h"
#import "MEKLocalSearchResultsViewController.h"
#import "MEKGlobalSearchResultsViewController.h"
#import <Masonry/Masonry.h>

@interface MEKCombinedSearchResultsViewController ()

@property (nonatomic, strong) MEKResultsViewController *activeResultsController;

@end

@implementation MEKCombinedSearchResultsViewController

#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _localResultsViewController = [[MEKLocalSearchResultsViewController alloc] init];
        _globalResultsViewController = [[MEKGlobalSearchResultsViewController alloc] init];
    }
    return self;
}

#pragma mark Properties

- (NSString *)query
{
    return self.activeResultsController.query;
}

- (void)setQuery:(NSString *)query
{
    if ([self.activeResultsController.query isEqualToString:query])
    {
        return;
    }

    self.activeResultsController.query = query;
}

- (void)setActiveResultsController:(MEKResultsViewController *)activeResultsController
{
    if (_activeResultsController == activeResultsController)
    {
        return;
    }

    _activeResultsController = activeResultsController;

    [self.localResultsViewController.viewIfLoaded removeFromSuperview];
    [self.globalResultsViewController.viewIfLoaded removeFromSuperview];

    [self.view addSubview:activeResultsController.view];
}

- (void)setCurrentType:(MEKResultsType)currentType
{
    _currentType = currentType;
    switch (currentType)
    {
        case MEKResultsNone:
            self.activeResultsController = nil;
            break;

        case MEKResultsLocal:
            self.activeResultsController = self.localResultsViewController;
            break;

        case MEKResultsGlobal:
            self.activeResultsController = self.globalResultsViewController;
            break;
    }
}

#pragma mark UIViewController

- (void)updateViewConstraints
{
    [self.activeResultsController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
    }];

    [super updateViewConstraints];
}

@end
