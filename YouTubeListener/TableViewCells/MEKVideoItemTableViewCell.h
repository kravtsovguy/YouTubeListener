//
//  MEKVideoItemTableViewCell.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEKVideoItemActionProtocol.h"

@interface MEKVideoItemTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MEKVideoItemActionProtocol> delegate;
@property (nonatomic, readonly) VideoItemMO *item;

- (void)setWithVideoItem: (VideoItemMO*) item addedToLibrary: (BOOL)isAddedToLibrary;
- (void)setDownloadProgress: (double)progress;
+ (CGFloat)height;

@end
