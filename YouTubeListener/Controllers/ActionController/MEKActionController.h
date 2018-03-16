//
//  MEKActionController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEKPropertyManagedObjectContextProtocol.h"
#import "MEKPropertyDownloadControllerProtocol.h"
#import "MEKPropertyPlayerControllerProtocol.h"

@interface MEKActionController : NSObject <MEKPropertyManagedObjectContextProtocol, MEKPropertyDownloadControllerProtocol, MEKPropertyPlayerControllerProtocol>


@end
