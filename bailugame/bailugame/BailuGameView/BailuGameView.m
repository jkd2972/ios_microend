//
//  BailuGameView.m
//  bailugame
//
//  Created by 闫佳奇 on 17/3/17.
//  Copyright © 2017年 egretteam. All rights reserved.
//

#import "BailuGameView.h"
#import "WechatManager.h"
#import "Navigation.h"
#import "MZManager.h"

@implementation BailuGameView

- (void)goBack
{
    [_mWebView goBack];
    [[Navigation getInstance] setCurrentUrl:_mWebView.URL.absoluteString];
}

- (void)reload
{
    [_mWebView reload];
}

- (void)share
{
    NSLog(@"++> share");
    
    [_mWebView evaluateJavaScript:@"window.DaKaShareWX()" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        
    }];
}

- (void)shareSuccess
{
    NSLog(@"++> share success");
    
    [_mWebView evaluateJavaScript:@"window.DakaShareSuccess()" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        
    }];
}

-(instancetype)initWithSuperView:(UIView*)superView
{
    if(self=[super init]){
        self.mSuperView = superView;
    }
    [self createWebView];
    return self;
}

-(void)sendScript:(NSString*)script toJavaScript:(WKWebView*)webView
{
    [webView evaluateJavaScript:script completionHandler:^(id object,NSError*error) {
        NSLog(@"%s-----%@,error%@",__func__,object,error);
        NSLog(@"-----%@", script);
    }];
}

-(void)createWebView
{
    if(self.mWebView == nil){
        self.mWebView = [self newWebKitView];
    }
    if(self.mWebView.superview == nil){
        [self.mSuperView addSubview:self.mWebView];
    }

    self.mWebView.UIDelegate = self;
    self.mWebView.navigationDelegate = self;
}

-(WKWebView*) newWebKitView
{
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    config.processPool = [[WKProcessPool alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    
    NSString* scriptSource = @"\
        window.dakaGameCenter={\
            payWX:function(data){\
                window.webkit.messageHandlers.payIOSWX.postMessage(data);\
            },\
            isWXInstalled:function(){\
                return true;\
            },\
            setTitle:function(str){\
                window.webkit.messageHandlers.setIOSTitle.postMessage(str);\
            },\
            loginWX:function(url){\
                window.webkit.messageHandlers.EgretIOSLoginWX.postMessage(url);\
            },\
            shareWX:function(str){\
                window.webkit.messageHandlers.shareIOSWX.postMessage(str);\
            }\
        };";
    WKUserScript* script = [[WKUserScript alloc] initWithSource:scriptSource
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:NO];
    [config.userContentController addUserScript:script];
    
    [config.userContentController addScriptMessageHandler:self name:@"EgretIOSLoginWX"];
    [config.userContentController addScriptMessageHandler:self name:@"payIOSWX"];
    [config.userContentController addScriptMessageHandler:self name:@"setIOSTitle"];
    [config.userContentController addScriptMessageHandler:self name:@"shareIOSWX"];
    
    
    [[MZManager shareInstance] initMZScript:config scriptMessageHandler:self];
    
    CGRect bound = CGRectMake([UIScreen mainScreen].bounds.origin.x,
                              [UIScreen mainScreen].bounds.origin.y + NavigationHeight,
                              [UIScreen mainScreen].bounds.size.width,
                              [UIScreen mainScreen].bounds.size.height - NavigationHeight);
    return [[WKWebView alloc] initWithFrame:bound
                              configuration:config];
    
}

-(void)removeMessageHandler
{
    [_mWebView.configuration.userContentController removeScriptMessageHandlerForName:@"EgretIOSLoginWX"];
    [_mWebView.configuration.userContentController removeScriptMessageHandlerForName:@"payIOSWX"];
    [_mWebView.configuration.userContentController removeScriptMessageHandlerForName:@"setIOSTitle"];
    [_mWebView.configuration.userContentController removeScriptMessageHandlerForName:@"shareIOSWX"];
    
    [[MZManager shareInstance] removeMessageHandler:_mWebView.configuration];
}

- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message
{
    NSLog(@"%s-----%@", __func__, message);
    if ([message.name isEqualToString:@"EgretIOSLoginWX"])
    {
        NSString* newUrl = message.body;
        [[WechatManager sharedManager] loginWXin:newUrl Handler:^(NSString* code, NSString* newUrl)
         {
            NSLog(@">>>>>> code: %@ %@", code, newUrl);
            
            newUrl = [newUrl stringByAppendingFormat:@"&code=%@", code];
            NSURL* url = [NSURL URLWithString:newUrl];
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            [_mWebView loadRequest:request];
        }];
    }
    else if ([message.name isEqualToString:@"payIOSWX"])
    {
        NSString* dataStr = message.body;
        NSLog(@">>> payIOSWX: %@", dataStr);
        NSData* jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* err;
        
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&err];
        
        if (err)
        {
            NSLog(@"json解析失败：%@", err);
            return;
        }
        
        [[WechatManager sharedManager] payWXWithPrepayID:[jsonDict objectForKey:@"prepayId"]
                                                NonceStr:[jsonDict objectForKey:@"nonceStr"]
                                                    Sign:[jsonDict objectForKey:@"sign"]];
    }
    else if ([message.name isEqualToString:@"setIOSTitle"])
    {
        NSString* title = message.body;
        NSLog(@"setTitle: %@", title);
        
        Navigation* navigation = [Navigation getInstance];
        if (navigation != NULL)
        {
            [navigation setTitle:title];
        }
    }
    else if ([message.name isEqualToString:@"shareIOSWX"])
    {
        NSString* dataStr = message.body;
        NSLog(@">>> shareIOSWX: %@", dataStr);
        NSData* jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError* err;
        
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&err];
        
        if (err)
        {
            NSLog(@"json解析失败：%@", err);
            return;
        }
        
        [[WechatManager sharedManager] setWebView:self];
        [[WechatManager sharedManager] shareWXWithLink:[jsonDict objectForKey:@"link"]
                                                 Title:[jsonDict objectForKey:@"title"]
                                                  Desc:[jsonDict objectForKey:@"desc"]
                                                 Image:[jsonDict objectForKey:@"imgUrl"]
                                                  Type:[jsonDict objectForKey:@"type"]];
    }else{
        [[MZManager shareInstance] userContentController:userContentController didReceiveScriptMessage:message webView:self.mWebView];
    }
}

-(void)webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation
{
    NSLog(@"%@ shouldStartLoad",webView.URL.absoluteString);
}

- (void)webView:(WKWebView*)webView didCommitNavigation:(null_unspecified WKNavigation*)navigation
{
    NSLog(@"%@ didStartLoad", webView.URL.absoluteString);
    [[Navigation getInstance] setCurrentUrl:webView.URL.absoluteString];
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(null_unspecified WKNavigation*)navigation
{
    NSLog(@"%@ didFinishLoad",webView.URL.absoluteString);
}

- (void)webView:(WKWebView*)webView didFailNavigation:(null_unspecified WKNavigation*)navigation withError:(NSError*)error{
    NSLog(@"%@ didFailLoadWithError %@",webView.URL.absoluteString,error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView*)webView NS_AVAILABLE(10_11, 9_0){
    
    NSLog(@"进程被终止");
    NSLog(@"%@",webView.URL);
//    processDidTerminated = YES;
//    [webView reload];
    
}

- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL* URL = navigationAction.request.URL;
    NSString* urlStr = [URL absoluteString];
    
    if ([urlStr hasPrefix:@"weixin://"])
    {
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
        [[WechatManager sharedManager] payWX:urlStr];
    }
    NSLog(@"%@", urlStr);
    [[Navigation getInstance] setCurrentUrl:webView.URL.absoluteString];
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
