//
//  MEKDowloadButton.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEKProgressBar.h"

@interface MEKDowloadButton : UIButton

@property (nonatomic, strong) MEKProgressBar *progressBar;
@property (nonatomic, assign) BOOL isLoading;

@end
