//
//  MEKResultsViewController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 19/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemTableViewController.h"

@interface MEKResultsViewController : MEKVideoItemTableViewController

@property (nonatomic, copy) NSString *query;

- (instancetype)initWithQuery: (NSString*) query;

@end
