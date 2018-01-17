//
//  MEKPlaylistViewController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 10/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKPlaylistViewController.h"
#import "VideoItemMO+CoreDataClass.h"
#import "AppDelegate.h"
#import <Masonry/Masonry.h>
#import "MEKVideoItemTableViewCell.h"
#import "MEKModalPlaylistsViewController.h"
#import "MEKYouTubeVideoParser.h"

@interface MEKPlaylistViewController () <MEKVideoItemDelegate, MEKModalPlaylistsViewControllerDelegate, MEKDownloadControllerDelegate, MEKWebVideoParserOutputProtocol>

@property (nonatomic, readonly) MEKPlayerController *playerController;
@property (nonatomic, readonly) MEKDownloadController *downloadController;
@property (nonatomic, strong) MEKWebVideoParser *parser;
@property (nonatomic, strong) PlaylistMO *playlist;
@property (nonatomic, weak) VideoItemMO *currentItem;

@end

@implementation MEKPlaylistViewController

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _parser = [MEKYouTubeVideoParser new];
        _parser.output = self;
    }
    return self;
}

- (instancetype)initWithPlaylist:(PlaylistMO *)playlist
{
    self = [self init];
    if (self)
    {
        _playlist = playlist;
    }
    
    return self;
}

#pragma mark - Properties

- (MEKPlayerController *)playerController
{
    UIApplication *application = [UIApplication sharedApplication];
    AppDelegate *appDelegate =  (AppDelegate*)application.delegate;
    MEKPlayerController *player = appDelegate.player;
    return player;
}

- (MEKDownloadController *)downloadController
{
    return self.playerController.downloadController;
}

- (NSManagedObjectContext*) coreDataContext
{
    return self.playerController.coreDataContext;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.playlist.name;
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[MEKVideoItemTableViewCell class] forCellReuseIdentifier:@"MEKVideoItemTableViewCell"];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.downloadController.delegate = self;
    [self loadItems];
}

#pragma mark - Private

- (void)updateData
{
    self.items = [self.playlist getVideoItems];
}

- (void)loadItems
{
    [self updateData];
    [self.tableView reloadData];
}

- (UIAlertAction*)createActionForQuality: (VideoItemQuality) quality
{
    NSString *qualityString = [VideoItemMO getQualityString:quality];
    NSString *name = qualityString;
    
    NSNumber *size = self.currentItem.sizes[@(quality)];
    if (![size isEqualToNumber:@(0)])
    {
        name = [NSString stringWithFormat:@"%@ (%@MB)", qualityString, size];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self videoItemDownload:self.currentItem withQuality:quality];
    }];
    
    return action;
}

- (void)showDownloadingDialog
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Quality"
                                                                   message:@"Available formats"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancedlAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:[self createActionForQuality:VideoItemQualityHD720]];
    [alert addAction:[self createActionForQuality:VideoItemQualityMedium360]];
    [alert addAction:[self createActionForQuality:VideoItemQualitySmall240]];
    [alert addAction:[self createActionForQuality:VideoItemQualitySmall144]];
    [alert addAction:cancedlAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MEKVideoItemTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MEKVideoItemTableViewCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    VideoItemMO *item = self.items[indexPath.row];
    
    double progress = [self.downloadController getProgressForKey:item.videoId];
    
    if ([item hasDownloaded])
        progress = 1;
    
    [cell setDownloadProgress:progress];
    
    [cell setWithVideoItem:item];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEKVideoItemTableViewCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VideoItemMO *item = self.items[indexPath.row];
    [self.playerController openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoItemMO *item = self.items[indexPath.row];
    
    UITableViewRowAction *unloadAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Unload"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [item removeDownloadAll];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    unloadAction.backgroundColor = UIColor.orangeColor;
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self.playlist deleteVideoItem:item];
        
        NSMutableArray *items = self.items.mutableCopy;
        [items removeObjectAtIndex:indexPath.row];
        self.items = items;
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    NSMutableArray *actions = [NSMutableArray new];
    [actions addObject:deleteAction];

    if ([item hasDownloaded])
    {
        [actions addObject:unloadAction];
    }
    
    return actions;
}

#pragma mark - MEKVideoItemDelegate

- (void)videoItemAddToPlaylist:(VideoItemMO *)item
{
    self.currentItem = item;
    
    MEKModalPlaylistsViewController *playlistsController = [MEKModalPlaylistsViewController new];
    playlistsController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)videoItemDownload: (VideoItemMO*) item;
{
    self.currentItem = item;
    
    if (item.urls)
    {
        [self showDownloadingDialog];
    }
    else
    {
        [self.parser loadVideoItem:item];
    }
}

- (void)videoItemDownload:(VideoItemMO *)item withQuality:(VideoItemQuality)quality
{
    [self.downloadController downloadDataFromURL:item.urls[@(quality)] forKey:item.videoId withParams:@{@"quality" : @(quality)}];
}

- (void)videoItemCancelDownload:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadForKey:item.videoId];
}

#pragma mark - MEKWebVideoParserOutputProtocol

- (void)webVideoParser:(id<MEKWebVideoParserInputProtocol>)parser didLoadItem:(VideoItemMO *)item
{
    [self videoItemDownload:item];
}

#pragma mark - MEKModalPlaylistsViewControllerDelegate

- (void)modalPlaylistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist
{
    [playlist addVideoItem:self.currentItem];
}

#pragma mark - MEKDownloadControllerDelegate

- (void)downloadControllerProgress:(double)progress forKey:(NSString *)key withParams:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (MEKVideoItemTableViewCell *cell in self.tableView.visibleCells)
        {
            VideoItemMO *item = cell.item;
            if ([key isEqualToString:item.videoId])
            {
                [cell setDownloadProgress:progress];

                if (progress == 1)
                {
                    [cell setWithVideoItem:item];
                }
//
                return;
            }
        }
    });
}

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoId == %@", key];
    VideoItemMO *item = [self.items filteredArrayUsingPredicate:predicate].firstObject;
    
    NSNumber *quality = params[@"quality"];
    [item saveTempPathURL:url withQuality:quality.unsignedIntegerValue];
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.items indexOfObject:item] inSection:0];

    [self downloadControllerProgress:1 forKey:key withParams:params];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    });
}

- (void)downloadControllerDidFinishWithError:(NSError *)error forKey:(NSString *)key withParams:(NSDictionary *)params
{
    if (error)
    {
        [self downloadControllerProgress:0 forKey:key withParams:params];
    }
}

@end
