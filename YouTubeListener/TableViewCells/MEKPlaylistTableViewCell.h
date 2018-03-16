//
//  MEKPlaylistTableViewCell.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaylistMO+CoreDataClass.h"
#import "VideoItemMO+CoreDataClass.h"

@interface MEKPlaylistTableViewCell : UITableViewCell

- (void)setWithName: (NSString *)playlistName itemsCount: (NSUInteger)count imageURL: (NSURL *)url;
+ (CGFloat)height;

@end
