//
//  MEKCachedSearchViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKSearchViewController.h"

@interface MEKCachedSearchViewController : MEKSearchViewController

@property (nonatomic, readonly) NSUserDefaults *userDefaults;

- (instancetype)initWithUserDefaults: (NSUserDefaults*) userDefaults;

@end
