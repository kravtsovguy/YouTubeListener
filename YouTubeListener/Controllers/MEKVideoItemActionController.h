//
//  MEKVideoItemActionController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 07/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEKVideoItemActionProtocol.h"
#import "MEKPropertyManagedObjectContextProtocol.h"
#import "MEKPropertyDownloadControllerProtocol.h"

@interface MEKVideoItemActionController : NSObject <MEKPropertyManagedObjectContextProtocol, MEKPropertyDownloadControllerProtocol, MEKVideoItemActionProtocol>

@property (nonatomic, weak) id<MEKVideoItemActionProtocol> delegate;

@end
