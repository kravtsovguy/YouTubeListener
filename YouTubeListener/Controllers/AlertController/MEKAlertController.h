//
//  MEKAlertController.h
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MEKAlertController : NSObject

@property (nonatomic, strong) UIViewController *viewController;

- (void)showViewController: (UIViewController *)viewController;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void)showDialogWithTitle: (NSString *)title message: (NSString *)message actions: (NSArray<UIAlertAction *> *)actions;
- (UIAlertAction *)actionWithTitle: (NSString *)title handler: (void (^)(void)) handler;

@end
