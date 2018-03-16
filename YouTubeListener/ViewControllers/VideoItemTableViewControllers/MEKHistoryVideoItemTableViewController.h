//
//  MEKHistoryVideoItemTableViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemTableViewController.h"

@interface MEKHistoryVideoItemTableViewController : MEKVideoItemTableViewController

@property (nonatomic, strong, readonly) NSUserDefaults *userDefaults;

- (instancetype)initWithUserDefaults: (NSUserDefaults *)userDefaults;

@end
