//
//  MEKCachedSearchViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKCachedSearchViewController.h"

static NSString * const MEKSearchQueriesDefaults = @"searchQueries";

@interface MEKCachedSearchViewController () <MEKSearchViewControllerDelegate>

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation MEKCachedSearchViewController

#pragma mark - init

- (instancetype)init
{
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    NSArray *queries = [userDefaults objectForKey:MEKSearchQueriesDefaults];
    
    self = [super initWithQueries:queries];
    if (self)
    {
        self.delegate = self;
        _userDefaults = userDefaults;
    }

    return self;
}

#pragma mark - MEKSearchViewControllerDelegate

- (void)searchViewControllerDidUpdateQueries:(MEKSearchViewController *)searchViewController
{
    [self.userDefaults setObject:searchViewController.queries forKey:MEKSearchQueriesDefaults];
    [self.userDefaults synchronize];
}

@end
