//
//  UIImageView+Cache.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 14/01/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "UIImageView+Cache.h"

@implementation UIImageView(Cache)


- (void)ch_saveData:(NSData*)data ForUrl: (NSURL*)url
{
    NSString *path = [self ch_getPathForUrl:url];
    
    NSError *error = nil;
    if (![data writeToFile:path options:NSAtomicWrite error:&error])
    {
        NSLog(@"Error Writing File : %@",error.localizedDescription);
    }
}

- (NSData*)ch_getDataForUrl: (NSURL*)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self ch_getPathForUrl:url];
    if([fileManager fileExistsAtPath:path])
    {
        return [NSData dataWithContentsOfFile:path];
    }
    else
    {
        return nil;
    }
}

- (NSString*)ch_getPathForUrl: (NSURL*)url
{
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *urlName = [self ch_getNameFromUrl:url];
    NSString *path = [documentsDirectoryPath stringByAppendingPathComponent:urlName];
    return path;
}

- (NSString*)ch_getNameFromUrl: (NSURL*)url
{
    NSString *path = url.path;
    path = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    return path;
}

- (void)ch_downloadImageFromUrl:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{

        NSData *data = [self ch_getDataForUrl:url];
        if (!data)
        {
            data = [NSData dataWithContentsOfURL:url];
            [self ch_saveData:data ForUrl:url];
        }
        
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            
                self.image = image;
                
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3f;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                
                [self.layer addAnimation:transition forKey:nil];
            
        });
    });
}

@end
