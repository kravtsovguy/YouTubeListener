//
//  MEKLibraryViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 11/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKLibraryViewController.h"
#import "MEKVideoItemTableViewController+Private.h"
#import "MEKPlaylistsViewController.h"
#import "MEKHistoryVideoItemTableViewController.h"
#import <objc/runtime.h>
#import "MEKVideoItemActionController.h"

@interface CellToViewControllerObject : NSObject

typedef UIViewController *(^ViewControllerBlock)(void);

@property (nonatomic, strong, readonly) UITableViewCell *cell;
@property (nonatomic, copy, nonnull, readonly) ViewControllerBlock viewControllerBlock;

- (instancetype)initWithCell: (UITableViewCell *)cell usingViewControllerBlock: (nonnull ViewControllerBlock)viewControllerBlock;

@end

@interface MEKLibraryViewController ()

@end

@interface MEKLibraryViewController (Cells)

@property (nonatomic, copy, readonly)  NSArray<CellToViewControllerObject *> *cells;
@property (nonatomic, strong, readonly) CellToViewControllerObject *playlistsCell;
@property (nonatomic, strong, readonly) CellToViewControllerObject *historyCell;
@property (nonatomic, strong, readonly) CellToViewControllerObject *offlineCell;
@property (nonatomic, strong, readonly) CellToViewControllerObject *titleCell;

@end

@implementation MEKLibraryViewController

#pragma mark - UIViewController

- (NSString *)title
{
    return self.offlineMode ? @"Offline Library" : @"Library";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.offlineMode)
    {
        return;
    }
    
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(p_playPressed:)];
    self.navigationItem.leftBarButtonItem = playItem;

    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(p_removeAllPressed:)];
    self.navigationItem.rightBarButtonItem = removeItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = self.offlineMode ? [UIColor lightGrayColor] : [UIColor whiteColor];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row >= self.cells.count)
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - self.cells.count inSection:indexPath.section];
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }

    return self.cells[indexPath.row].cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count + [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.cells.count)
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - self.cells.count inSection:indexPath.section];
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }

    return UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.cells.count)
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - self.cells.count inSection:indexPath.section];
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController *viewController = self.cells[indexPath.row].viewControllerBlock();
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Private

- (void)p_playPressed: (id) sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (![pasteboard hasStrings])
    {
        return;
    }

    NSURL *url = [NSURL URLWithString:pasteboard.string];
    [self.actionController.videoItemActionController videoItemPlayURL:url];
}

- (void)p_removeAllPressed: (id) sender
{
    [self.actionController showClearLibraryDialog];
}

@end

@implementation CellToViewControllerObject

- (instancetype)initWithCell:(UITableViewCell *)cell usingViewControllerBlock:(ViewControllerBlock)viewControllerBlock
{
    self = [super init];
    if (self)
    {
        _cell = cell;
        _viewControllerBlock = [viewControllerBlock copy];
    }
    return self;
}

@end

@implementation MEKLibraryViewController (Cells)

- (NSArray<CellToViewControllerObject *> *)cells
{
    NSArray *cells = objc_getAssociatedObject(self, @selector(cells));
    if (!cells)
    {
        cells = @[self.playlistsCell, self.historyCell, self.offlineCell, self.titleCell];

        if (self.offlineMode)
        {
            cells = @[self.playlistsCell, self.historyCell, self.titleCell];
        }

        objc_setAssociatedObject(self, @selector(cells), cells, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }

    return cells;
}

- (CellToViewControllerObject *)playlistsCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Playlists";

    return [[CellToViewControllerObject alloc] initWithCell:cell usingViewControllerBlock:^UIViewController *{
        MEKPlaylistsViewController *viewController = [[MEKPlaylistsViewController alloc] init];
        viewController.offlineMode = self.offlineMode;
        
        return viewController;
    }];
}

- (CellToViewControllerObject *)historyCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"History";

    return [[CellToViewControllerObject alloc] initWithCell:cell usingViewControllerBlock:^UIViewController *{
        MEKHistoryVideoItemTableViewController *viewController = [[MEKHistoryVideoItemTableViewController alloc] init];
        viewController.offlineMode = self.offlineMode;

        return viewController;
    }];
}

- (CellToViewControllerObject *)offlineCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Offline Library";

    return [[CellToViewControllerObject alloc] initWithCell:cell usingViewControllerBlock:^UIViewController *{
        MEKLibraryViewController *viewController = [[MEKLibraryViewController alloc] init];
        viewController.offlineMode = YES;

        return viewController;
    }];
}

- (CellToViewControllerObject *)titleCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = super.title;
    cell.textLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return [[CellToViewControllerObject alloc] initWithCell:cell usingViewControllerBlock:^UIViewController *{
        return nil;
    }];
}

@end
