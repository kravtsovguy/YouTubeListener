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

@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, assign, getter=isDone) BOOL done;

- (void)setProgress: (double)progress;

@end
