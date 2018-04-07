//
//  MEKSearchViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 21/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKSearchViewController.h"
#import "MEKYouTubeAPI.h"
#import "MEKCombinedSearchResultsViewController.h"

@interface MEKSearchViewController () <UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSArray<NSString*> *queries;

@property (nonatomic, copy) NSString *query;
@property (nonatomic, readonly) NSPredicate *predicate;
@property (nonatomic, readonly) NSArray<NSString*> *filteredQueries;

@property (nonatomic, strong) MEKCombinedSearchResultsViewController *resultsViewController;

@end

@implementation MEKSearchViewController

#pragma mark - init

- (instancetype)init
{
    return [self initWithQueries:nil];
}

- (instancetype)initWithQueries:(NSArray<NSString *> *)queries
{
    self = [super init];
    if (self)
    {
        _queries = queries ? [queries copy] : @[];
    }
    return self;
}

#pragma mark - Properties

- (void)setQuery:(NSString *)query
{
    self.searchController.searchBar.text = query;
    self.searchController.active = YES;
}

- (NSString *)query
{
    NSString *query = self.searchController.searchBar.text;
    return query;
}

- (NSPredicate *)predicate
{
    NSPredicate *predicate = (self.query.length == 0) ? nil : [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", self.query];
    return predicate;
}

- (NSArray<NSString *> *)filteredQueries
{
    if (!self.predicate)
    {
        return self.queries;
    }

    NSArray *filteredQueries = [self.queries filteredArrayUsingPredicate:self.predicate];
    return filteredQueries;
}

- (void)setQueries:(NSArray<NSString *> *)queries
{
    _queries = [queries copy];

    if ([self.delegate respondsToSelector:@selector(searchViewControllerDidUpdateQueries:)])
    {
        [self.delegate searchViewControllerDidUpdateQueries:self];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Search";
    self.view.backgroundColor = [UIColor whiteColor];

    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(p_removeAllPressed:)];
    self.navigationItem.rightBarButtonItem = removeItem;

    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

    self.resultsViewController = [[MEKCombinedSearchResultsViewController alloc] init];

    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsViewController];
    searchController.searchResultsUpdater = self;

    searchController.searchBar.delegate = self;
    searchController.searchBar.placeholder = @"Search by videos";
    searchController.searchBar.scopeButtonTitles = @[@"Global", @"Local"];
    searchController.searchBar.selectedScopeButtonIndex = 1;
    searchController.searchBar.showsScopeBar = NO;

    searchController.dimsBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.definesPresentationContext = YES;

    self.searchController = searchController;
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = self.filteredQueries[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredQueries.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"History";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.query = self.filteredQueries[indexPath.row];
    [self searchBarSearchButtonClicked:self.searchController.searchBar];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){

        NSString *query = self.filteredQueries[indexPath.row];
        [self p_removeSearchForQuery:query];

        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];

    return @[deleteAction];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

    [self p_addSearchForQuery:self.query];
    [self p_updateResultsControllerWithSearchBar:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self p_updateResultsControllerWithSearchBar:searchBar];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController
{
    [self.tableView reloadData];

    if (searchController.searchBar.selectedScopeButtonIndex == 0)
    {
        self.resultsViewController.view.hidden = YES;
    }

    if (searchController.searchBar.selectedScopeButtonIndex == 1)
    {
        [self p_updateResultsControllerWithSearchBar:searchController.searchBar];
    }
}

#pragma mark - Private

- (void)p_updateResultsControllerWithSearchBar: (UISearchBar *)searchBar
{
    if (self.query.length == 0)
    {
        self.resultsViewController.view.hidden = YES;
        return;
    }

    self.resultsViewController.view.hidden = NO;
    self.resultsViewController.currentType = searchBar.selectedScopeButtonIndex == 0 ? MEKResultsGlobal : MEKResultsLocal;
    self.resultsViewController.query = self.query;
}

- (void)p_removeSearchForQuery: (NSString *) query
{
    NSMutableArray *queries = self.queries.mutableCopy;
    [queries removeObject:query];

    self.queries = queries;

    if ([self.delegate respondsToSelector:@selector(searchViewController:didRemoveQuery:)])
    {
        [self.delegate searchViewController:self didRemoveQuery:query];
    }
}

- (void)p_addSearchForQuery: (NSString *) query
{
    NSMutableArray *queries = self.queries.mutableCopy;
    [queries removeObject:query];
    [queries insertObject:query atIndex:0];

    self.queries = queries;

    if ([self.delegate respondsToSelector:@selector(searchViewController:didAddQuery:)])
    {
        [self.delegate searchViewController:self didAddQuery:query];
    }
}

- (void)p_removeAllPressed: (id) sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"Clear you search history?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.queries = @[];
    }];

    UIAlertAction *cancedlAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:deleteAction];
    [alert addAction:cancedlAction];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
