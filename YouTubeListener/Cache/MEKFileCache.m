//
//  MEKFileCache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 02/03/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKFileCache.h"
#import <UIKit/UIKit.h>

@interface MEKFileItem : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, copy) NSData *data;

@end

@implementation MEKFileItem
@end

@interface MEKFileCache ()

@property (nonatomic, readonly) NSFileManager *fileManager;
@property (nonatomic, readonly) NSString *directoryPath;

@property (nonatomic, assign) NSUInteger bufferCount;
@property (nonatomic, assign) NSUInteger bufferSizeBytes;
@property (nonatomic, strong) NSMutableDictionary <NSString *, MEKFileItem *> *buffer;

@end

@implementation MEKFileCache

- (instancetype)init
{
    return [self initWithDirectoryName:@"Cache"];
}

- (instancetype)initWithDirectoryName:(NSString *)directoryName
{
    self = [super init];
    if (self)
    {
        _directoryName = [directoryName copy];

        _countLimit = 100;
        _sizeBytesLimit = 1 * 1024 * 1024;

        _bufferCountLimit = 20;
        _bufferSizeBytesLimit = 100 * 1024;

        _buffer = @{}.mutableCopy;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
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
    MEKFileItem *fileItem = self.buffer[filePath];

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
    NSString *filePath = [self p_filePathForKey:key];

    if (object)
    {
        NSData *data = object;
        MEKFileItem *fileItem = [MEKFileItem new];
        fileItem.path = filePath;
        fileItem.size = data.length;
        fileItem.data = data;
        fileItem.date = [NSDate new];
        [self p_setObjectToBuffer:fileItem forKey:filePath];

        BOOL isOverCount = self.bufferCountLimit > 0 && self.bufferCount > self.bufferCountLimit;
        BOOL isOverSize = self.bufferSizeBytesLimit > 0 && self.bufferSizeBytes > self.bufferSizeBytesLimit;

        if (isOverCount || isOverSize)
        {
            [self p_saveBuffer];
        }
    }
    else
    {
        [self p_setObjectToBuffer:nil forKey:filePath];
        [self.fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)removeAllObjects
{
    NSArray *fileArray = [self p_loadFilesForDirectory:self.directoryPath].allValues;
    [self p_removeFiles:fileArray];
    [self p_resetBuffer];
}

- (void)p_removeFiles: (NSArray <MEKFileItem *> *)fileArray
{
    [fileArray enumerateObjectsUsingBlock:^(MEKFileItem * _Nonnull fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.fileManager removeItemAtPath:fileItem.path error:nil];
    }];
}

- (void)p_resetBuffer
{
    self.bufferCount = 0;
    self.bufferSizeBytes = 0;
    self.buffer = @{}.mutableCopy;
}

- (void)p_setObjectToBuffer: (MEKFileItem *)fileItem forKey: (NSString *)key
{
    MEKFileItem *currentFileItem = self.buffer[key];

    if (fileItem)
    {
        if (currentFileItem)
        {
            return;
        }

        self.buffer[key] = fileItem;
        self.bufferSizeBytes += fileItem.size;
        self.bufferCount += 1;
    }
    else
    {
        if (!currentFileItem)
        {
            return;
        }

        self.buffer[key] = nil;
        self.bufferSizeBytes -= currentFileItem.size;
        self.bufferCount -= 1;
    }
}

- (void)p_saveBuffer
{
    NSArray *fileArray = [self p_loadFilesForDirectory:self.directoryPath].allValues;
    fileArray = [fileArray arrayByAddingObjectsFromArray:self.buffer.allValues];

    [self p_processFiles:fileArray];
    [self p_resetBuffer];
}

- (NSArray<MEKFileItem *> *)p_sortedFileArray: (NSArray<MEKFileItem *> *) fileArray
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    fileArray = [fileArray sortedArrayUsingDescriptors:@[descriptor]];
    return fileArray;
}

- (NSUInteger)p_filesSizeFromArray: (NSArray<MEKFileItem *> *) fileArray
{
    __block NSUInteger directorySizeBytes = 0;
    [fileArray enumerateObjectsUsingBlock:^(MEKFileItem * _Nonnull fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
        directorySizeBytes += fileItem.size;
    }];

    return directorySizeBytes;
}

- (void)p_createDirectoryIfNeeded: (NSString *)directoryPath
{
    if (![self.fileManager fileExistsAtPath:directoryPath isDirectory:nil])
    {
        [self.fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)p_processFiles: (NSArray <MEKFileItem *> *)fileArray
{
    [self p_createDirectoryIfNeeded:self.directoryPath];

    NSUInteger directoryFilesCount = fileArray.count;
    NSUInteger directorySizeBytes = [self p_filesSizeFromArray:fileArray];

    __block NSUInteger removingCount = 0;
    __block NSUInteger removingSizeBytes = 0;

    fileArray = [self p_sortedFileArray:fileArray];
    [fileArray enumerateObjectsUsingBlock:^(MEKFileItem * _Nonnull fileItem, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isOverCount = self.countLimit > 0 && (directoryFilesCount - removingCount) > self.countLimit;
        BOOL isOverSize = self.sizeBytesLimit > 0 && (directorySizeBytes - removingSizeBytes) > self.sizeBytesLimit;

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

- (NSString *)p_fileNameForKey: (NSString *) key
{
    NSString *name = key;
    name = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    return name;
}

- (NSString *)p_filePathForKey: (NSString *) key
{
    NSString *name = [self p_fileNameForKey:key];
    NSString *filePath = [self.directoryPath stringByAppendingPathComponent:name];
    return filePath;
}

- (NSMutableDictionary<NSString *, MEKFileItem *> *)p_loadFilesForDirectory: (NSString *)directoryPath
{
    NSMutableDictionary *files = @{}.mutableCopy;

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
            files[filePath] = fileItem;
        }
    }];

    return files;
}

- (void)p_appWillResignActive:(NSNotification*)note
{
    [self p_saveBuffer];
}


@end
