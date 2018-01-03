//
//  MEKSearchViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 03/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKSearchViewController.h"
#import <Masonry/Masonry.h>

@interface MEKSearchViewController ()

@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation MEKSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *superview = self.view;
    
    self.searchTextField = [UITextField new];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top).with.offset(padding.top);
    }];
}

@end
