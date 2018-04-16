//
//  MEKVideoItemActionController+Private.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 17/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemActionController.h"
#import "MEKWebVideoLoader.h"
#import "VideoItemMO+CoreDataClass.h"

@interface MEKVideoItemActionController () <MEKWebVideoLoaderOutputProtocol>

@property (nonatomic, strong) MEKWebVideoLoader *loader;
@property (nonatomic, strong) MEKWebVideoLoader *qualityLoader;
@property (nonatomic, strong) MEKWebVideoLoader *playLoader;

@end
