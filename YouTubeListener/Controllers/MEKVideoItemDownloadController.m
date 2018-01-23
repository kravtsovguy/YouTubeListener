//
//  MEKVideoItemDownloadController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 23/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKVideoItemDownloadController.h"

@interface MEKVideoItemDownloadController() <MEKDownloadControllerDelegate>

@property (nonatomic, strong) MEKDownloadController *downloadController;
@property (nonatomic, copy) NSMutableDictionary *items;

@end

@implementation MEKVideoItemDownloadController

#pragma mark - init

- (instancetype)initWithDownloadController:(MEKDownloadController *)downloadController
{
    self = [super init];
    if (self)
    {
        _items = [NSMutableDictionary new];
        
        _downloadController = downloadController;
        _downloadController.delegate = self;
    }
    
    return self;
}

#pragma mark - Public

- (void)downloadVideoItem:(VideoItemMO *)item withQuality:(VideoItemQuality)quality
{
    if (!item)
    {
        return;
    }
    
    self.items[item.videoId] = item;
    [self.downloadController downloadDataFromURL:item.urls[@(quality)] forKey:item.videoId withParams:@{@"quality" : @(quality)}];
}

- (BOOL)downloadingVideoItem:(VideoItemMO *)item
{
    return [self.downloadController hasTaskForKey:item.videoId];
}

- (double)getProgressForVideoItem:(VideoItemMO *)item
{
    return [self.downloadController getProgressForKey:item.videoId];
}

- (void)cancelDownloadingVideoItem:(VideoItemMO *)item
{
    [self.downloadController cancelDownloadForKey:item.videoId];
}

#pragma mark - MEKDownloadControllerDelegate

- (void)downloadControllerProgress:(double)progress forKey:(NSString *)key withParams:(NSDictionary *)params
{
    VideoItemMO *item = self.items[key];
    
    if ([self.delegate respondsToSelector:@selector(videoItemDownloadControllerProgress:forVideoItem:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate videoItemDownloadControllerProgress:progress forVideoItem:item];
        });
    }
}

- (void)downloadControllerDidFinishWithTempUrl:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    VideoItemMO *item = self.items[key];
    NSNumber *quality = params[@"quality"];
    [item saveTempPathURL:url withQuality:quality.unsignedIntegerValue];
}

- (void)downloadControllerDidFinishWithError:(NSError *)error forKey:(NSString *)key withParams:(NSDictionary *)params
{
    VideoItemMO *item = self.items[key];
    [self.items removeObjectForKey:key];
    
    if ([self.delegate respondsToSelector:@selector(videoItemDownloadControllerDidFinishWithError:forVideoItem:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate videoItemDownloadControllerDidFinishWithError:error forVideoItem:item];
        });
    }
}

@end
