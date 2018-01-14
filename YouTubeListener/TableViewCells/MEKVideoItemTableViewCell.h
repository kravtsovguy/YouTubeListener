//
//  MEKVideoItemTableViewCell.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItemMO+CoreDataClass.h"

@protocol MEKVideoItemTableViewCellDelegate <NSObject>

@optional

- (void)videoItemAddToPlaylistPressed: (VideoItemMO*) item;
- (void)videoItemDownloadPressed: (VideoItemMO*) item;

@end

@interface MEKVideoItemTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MEKVideoItemTableViewCellDelegate> delegate;

- (void)setWithPlaylist: (VideoItemMO*) item;
+ (CGFloat)height;

@end
