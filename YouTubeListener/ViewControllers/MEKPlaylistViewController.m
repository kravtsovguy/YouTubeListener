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
#import "VideoItemDelegate.h"
#import "MEKModalPlaylistsViewController.h"

@interface MEKPlaylistViewController () <MEKVideoItemDelegate, MEKPlaylistsViewControllerDelegate, MEKDownloadControllerDelegate, YouTubeParserDelegate>

@property (nonatomic, readonly) MEKPlayerController *playerController;
@property (nonatomic, readonly) MEKDownloadController *downloadController;
@property (nonatomic, strong) YouTubeParser *parser;
@property (nonatomic, strong) PlaylistMO *playlist;
@property (nonatomic, weak) VideoItemMO *currentItem;

@end

@implementation MEKPlaylistViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _parser = [YouTubeParser new];
        _parser.delegate = self;
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

- (NSManagedObjectContext*) coreDataContext
{
    UIApplication *application = [UIApplication sharedApplication];
    NSPersistentContainer *container = ((AppDelegate*)(application.delegate)).persistentContainer;
    
    NSManagedObjectContext *context = container.viewContext;
    
    return context;
}

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

- (void)viewDidLoad {
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.downloadController.delegate = self;
    [self loadItems];
}

- (void)updateData
{
    self.items = [self.playlist getVideoItems];
}

- (void)loadItems
{
    [self updateData];
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MEKVideoItemTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MEKVideoItemTableViewCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    VideoItemMO *item = self.items[indexPath.row];
    
    [cell setWithPlaylist:item];
    
    double progress = [self.downloadController getProgressForKey:item.videoId];
    
    if ([item hasDownloaded])
        progress = 1;
    
    [cell setDownloadProgress:progress];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEKVideoItemTableViewCell height];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VideoItemMO *item = self.items[indexPath.row];
    [self.playerController openVideoItem:item withVisibleState:MEKPlayerVisibleStateMinimized];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self.playlist deleteVideoItem:self.items[indexPath.row]];
        
        NSMutableArray *items = self.items.mutableCopy;
        [items removeObjectAtIndex:indexPath.row];
        self.items = items;
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return @[deleteAction];
}

- (void)videoItemAddToPlaylist:(VideoItemMO *)item
{
    self.currentItem = item;
    
    MEKModalPlaylistsViewController *playlistsController = [MEKModalPlaylistsViewController new];
    playlistsController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:playlistsController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)videoItemDownload:(VideoItemMO *)item
{
    if (item.urls)
    {
        NSNumber *quality = @(VideoItemQualityMedium360);
        [self.downloadController downloadDataFromURL:item.urls[quality] forKey:item.videoId withParams:@{@"quality" : quality}];
    }
    else
    {
        [self.parser loadVideoItem:item];
    }
}

- (void)videoItemCancelDownload:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadForKey:item.videoId];
}

- (void)playlistsViewControllerDidChoosePlaylist:(PlaylistMO *)playlist
{
    [playlist addVideoItem:self.currentItem];
}

- (void)downloadControllerProgress:(double)progress forKey:(NSString *)key withParams:(NSDictionary *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (MEKVideoItemTableViewCell *cell in self.tableView.visibleCells)
        {
            VideoItemMO *item = [cell getItem];
            if ([key isEqualToString:item.videoId])
            {
                [cell setDownloadProgress:progress];
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
}

- (void)youtubeParserItemDidLoad:(VideoItemMO *)item
{
    [self videoItemDownload:item];
}

@end
