//
//  MEKPropertyPlayerControllerProtocol.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 08/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MEKPlayerController;

@protocol MEKPropertyPlayerControllerProtocol

@property (nonatomic, strong, readonly) MEKPlayerController *playerController;

@end
