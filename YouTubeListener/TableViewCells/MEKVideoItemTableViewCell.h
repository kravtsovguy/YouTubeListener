//
//  MEKVideoItemTableViewCell.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItemMO+CoreDataClass.h"
#import "MEKDowloadButton.h"

@interface MEKVideoItemTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MEKVideoItemDelegate> delegate;
@property (nonatomic, readonly) VideoItemMO *item;

- (void)setWithVideoItem: (VideoItemMO*) item;
- (void)setDownloadProgress: (double)progress;
+ (CGFloat)height;

@end
