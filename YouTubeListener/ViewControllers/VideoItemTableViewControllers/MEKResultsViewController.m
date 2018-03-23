//
//  MEKResultsViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 19/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKResultsViewController.h"

@interface MEKResultsViewController ()

@end

@implementation MEKResultsViewController

#pragma mark init

- (instancetype)initWithQuery:(NSString *)query
{
    self = [self init];
    if (self)
    {
        _query = [query copy];
    }
    return self;
}

#pragma mark - UIViewController

- (NSString *)title
{
    return self.query;
}

@end
