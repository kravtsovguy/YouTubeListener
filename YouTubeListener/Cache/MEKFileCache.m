//
//  MEKFileCache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKFileCache.h"
#import <UIKit/UIKit.h>
#import "MEKBufferCache.h"

@interface MEKFileItem : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, copy) NSData *data;

@end

@implementation MEKFileItem
@end

@interface MEKFileCache () <MEKBufferCacheDelegate>

@property (nonatomic, readonly) NSFileManager *fileManager;
@property (nonatomic, readonly) NSString *directoryPath;

@end

@implementation MEKFileCache

- (instancetype)init
{
    return [self initWithDirectoryName:@"Cache"];
}

- (instancetype)initWithDirectoryName:(NSString *)directoryName
{
    MEKBufferCache *buffer = [[MEKBufferCache alloc] init];
    
    return [self initWithDirectoryName:directoryName withBuffer:buffer];
}

- (instancetype)initWithDirectoryName:(NSString *)directoryName withBuffer:(MEKBufferCache *)buffer
{
    self = [super init];
    if (self)
    {
        _directoryName = [directoryName copy];

        _bufferCache = buffer;
        _bufferCache.delegate = self;

        self.countLimit = 200;
        self.totalCostLimit = 50 * 1024 * 1024;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSFileManager *)fileManager
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return fileManager;
}

- (NSString *)directoryPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:self.directoryName];
    return path;
}

- (id)objectForKey:(NSString *)key
{
    NSData *data;

    NSString *filePath = [self p_filePathForKey:key];
    MEKFileItem *fileItem = [self.bufferCache objectForKey:filePath];

    if (fileItem)
    {
        data = fileItem.data;
    }
    else
    {
        if ([self.fileManager fileExistsAtPath:filePath])
        {
            data = [NSData dataWithContentsOfFile:filePath];
        }
    }

    return data;
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost
{
    NSString *filePath = [self p_filePathForKey:key];

    if (object)
    {
        NSData *data = object;
        MEKFileItem *fileItem = [MEKFileItem new];
        fileItem.path = filePath;
        fileItem.size = data.length;
        fileItem.data = data;
        fileItem.date = [NSDate new];
        [self.bufferCache setObject:fileItem forKey:filePath withCost:fileItem.size];
    }
    else
    {
        [self.bufferCache setObject:nil forKey:filePath];
        [self.fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)removeAllObjects
{
    [self.fileManager removeItemAtPath:self.directoryPath error:nil];
    [self.bufferCache removeAllObjects];
}

- (void)p_saveBuffer:(NSArray<MEKFileItem *> *)buffer
{
    NSArray *fileArray = [self p_loadFilesForDirectory:self.directoryPath];
    fileArray = [fileArray arrayByAddingObjectsFromArray:buffer];

    [self p_processFiles:fileArray];
}

- (NSArray<MEKFileItem *> *)p_sortedFileArray:(NSArray<MEKFileItem *> *)fileArray
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    fileArray = [fileArray sortedArrayUsingDescriptors:@[descriptor]];
    return fileArray;
}

- (NSUInteger)p_filesSizeFromArray:(NSArray<MEKFileItem *> *)fileArray
{
    __block NSUInteger directorySizeBytes = 0;
    [fileArray enumerateObjectsUsingBlock:^(MEKFileItem * _Nonnull fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
        directorySizeBytes += fileItem.size;
    }];

    return directorySizeBytes;
}

- (void)p_createDirectoryIfNeeded:(NSString *)directoryPath
{
    if (![self.fileManager fileExistsAtPath:directoryPath isDirectory:nil])
    {
        [self.fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)p_processFiles:(NSArray <MEKFileItem *> *)fileArray
{
    [self p_createDirectoryIfNeeded:self.directoryPath];

    NSUInteger directoryFilesCount = fileArray.count;
    NSUInteger directorySizeBytes = [self p_filesSizeFromArray:fileArray];

    __block NSUInteger removingCount = 0;
    __block NSUInteger removingSizeBytes = 0;

    fileArray = [self p_sortedFileArray:fileArray];
    [fileArray enumerateObjectsUsingBlock:^(MEKFileItem * _Nonnull fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isOverCount = 0 < self.countLimit && self.countLimit < (directoryFilesCount - removingCount);
        BOOL isOverSize =  0 < self.totalCostLimit && self.totalCostLimit < (directorySizeBytes - removingSizeBytes);

        BOOL shouldDelete = isOverCount ||isOverSize;
        BOOL shouldSave = fileItem.data;

        if (shouldDelete)
        {
            removingSizeBytes += fileItem.size;
            removingCount += 1;
            [self.fileManager removeItemAtPath:fileItem.path error:nil];
        }

        if (!shouldDelete && shouldSave)
        {
            [fileItem.data writeToFile:fileItem.path options:NSDataWritingAtomic error:nil];
        }
    }];
}

- (NSArray<MEKFileItem *> *)p_loadFilesForDirectory:(NSString *)directoryPath
{
    NSMutableArray *fileArray = @[].mutableCopy;

    NSArray *filePathArray = [self.fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    [filePathArray enumerateObjectsUsingBlock:^(NSString * _Nonnull fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        NSDictionary *fileDictionary = [self.fileManager attributesOfItemAtPath:filePath error:nil];
        if (fileDictionary)
        {
            MEKFileItem *fileItem = [MEKFileItem new];
            fileItem.path = filePath;
            fileItem.size = [fileDictionary fileSize];
            fileItem.date = [fileDictionary fileCreationDate];
            [fileArray addObject:fileItem];
        }
    }];

    return fileArray;
}

- (NSString *)p_fileNameForKey:(NSString *)key
{
    NSString *name = key;
    name = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    return name;
}

- (NSString *)p_filePathForKey:(NSString *)key
{
    NSString *name = [self p_fileNameForKey:key];
    NSString *filePath = [self.directoryPath stringByAppendingPathComponent:name];
    return filePath;
}

- (void)p_appWillResignActive
{
    MEKBufferCache *bufferCache = self.bufferCache;

    [self p_saveBuffer:bufferCache.buffer.allValues];
    [bufferCache removeAllObjects];
}

- (void)bufferCacheDidFilled:(MEKBufferCache *)bufferCache
{
    [self p_saveBuffer:bufferCache.buffer.allValues];
}

@end
