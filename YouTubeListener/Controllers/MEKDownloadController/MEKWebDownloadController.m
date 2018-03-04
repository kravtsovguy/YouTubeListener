//
//  MEKWebDownloadController.m
//  YouTubeListener
//
//  Created by Matvey Kravtsov on 12/02/2018.
//  Copyright © 2018 Matvey Kravtsov. All rights reserved.
//

#import "MEKWebDownloadController.h"
#import "AppDelegate.h"

@interface MEKWebDownloadController () <UIWebViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *webViews;
@property (nonatomic, strong) NSMutableDictionary *params;

@end

@implementation MEKWebDownloadController

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _webViews = @{}.mutableCopy;
        _params = @{}.mutableCopy;
    }

    return self;
}

#pragma mark - Private

- (NSString*)findKeyByView: (UIWebView*) webView
{
    NSString *key;
    for (NSString *tempKey in self.webViews)
    {
        UIWebView *view = self.webViews[tempKey];
        if (view == webView)
        {
            key = tempKey;
        }
    }

    return key;
}

- (void)removeDownloadForKey: (NSString *)key
{
    [self.webViews removeObjectForKey:key];
    [self.params removeObjectForKey:key];
}

#pragma mark - MEKDownloadControllerInputProtocol

- (void)downloadDataFromURL:(NSURL *)url forKey:(NSString *)key withParams:(NSDictionary *)params
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self downloadDataFromRequest:request forKey:key withParams:params];
}

- (void)downloadDataFromRequest:(NSURLRequest *)request forKey:(NSString *)key withParams:(NSDictionary *)params
{
    if (!request || !key || [self hasDownloadForKey:key])
    {
        return;
    }

    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    [webView loadRequest:request];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:webView];

    self.webViews[key] = webView;
    self.params[key] = params;
}

- (void)cancelDownloadForKey:(NSString *)key
{
    UIWebView *webView = self.webViews[key];
    if (!webView)
    {
        return;
    }

    [webView stopLoading];
    [webView removeFromSuperview];
    [self removeDownloadForKey:key];
}

- (void)cancelAllDownloads
{
    if (self.webViews.count == 0)
    {
        return;
    }
    
    [self.webViews.allValues makeObjectsPerformSelector:@selector(stopLoading)];
    [self.webViews.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.webViews = @{}.mutableCopy;
    self.params = @{}.mutableCopy;
}

- (BOOL)hasDownloadForKey:(NSString *)key
{
    return self.webViews[key] != nil;
}

- (double)progressForKey:(NSString *)key
{
    UIWebView *webView = self.webViews[key];
    double progress = webView.isLoading ? 0 : 1;
    return progress;
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *content = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];

    NSString *key = [self findKeyByView:webView];
    NSDictionary *params = self.params[key];

    NSString *fileName = [NSString stringWithFormat:@"%@.html", [[NSProcessInfo processInfo] globallyUniqueString]];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];

    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];

    BOOL done = YES;

    if ([self.delegate respondsToSelector:@selector(downloadControllerDidFinish:withTempUrl:forKey:withParams:)])
    {
        done = [self.delegate downloadControllerDidFinish:self withTempUrl:fileURL forKey:key withParams:params];
    }

    if (done)
    {
        [self cancelDownloadForKey:key];
    }

    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSString *key = [self findKeyByView:webView];
    NSDictionary *params = self.params[key];

    [self cancelDownloadForKey:key];

    if ([self.delegate respondsToSelector:@selector(downloadControllerDidFinish:withError:forKey:withParams:)])
    {
        [self.delegate downloadControllerDidFinish:self withError:error forKey:key withParams:params];
    }
}

@end
