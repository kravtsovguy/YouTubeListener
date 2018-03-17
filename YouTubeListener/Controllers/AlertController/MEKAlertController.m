//
//  MEKAlertController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 15/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKAlertController.h"

@interface MEKAlertController ()

@end

@implementation MEKAlertController

#pragma mark Properties

- (UIViewController *)viewController
{
    if (_viewController)
    {
        return _viewController;
    }

    UIApplication *application = [UIApplication sharedApplication];
    UIViewController *viewController = application.keyWindow.rootViewController;

    while (viewController.presentedViewController)
    {
        viewController = viewController.presentedViewController;
    }

    return viewController;
}

#pragma mark Public

- (void)showViewController:(UIViewController *)viewController
{
    [self.viewController presentViewController:viewController animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                     handler:nil];

    [alert addAction:okAction];

    [self showViewController:alert];
}

- (void)showDialogWithTitle: (NSString *)title message: (NSString *)message actions: (NSArray<UIAlertAction *> *)actions
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [actions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull action, NSUInteger idx, BOOL * _Nonnull stop) {
        [alert addAction:action];
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self showViewController:alert];
}

- (UIAlertAction *)actionWithTitle: (NSString *)title handler: (void (^ __nullable)(void)) handler
{
    return [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler();
    }];
}

@end
