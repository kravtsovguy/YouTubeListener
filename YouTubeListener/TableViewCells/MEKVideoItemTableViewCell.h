//
//  MEKVideoItemTableViewCell.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItemMO+CoreDataClass.h"

@interface MEKVideoItemTableViewCell : UITableViewCell

- (void)setWithPlaylist: (VideoItemMO*) item;
+ (CGFloat)height;

@end
