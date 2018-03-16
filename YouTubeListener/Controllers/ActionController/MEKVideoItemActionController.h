//
//  MEKVideoItemActionController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 07/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEKActionController.h"
#import "MEKVideoItemActionProtocol.h"

@interface MEKVideoItemActionController : MEKActionController <MEKVideoItemActionProtocol>

@property (nonatomic, weak) id<MEKVideoItemActionProtocol> delegate;

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end
