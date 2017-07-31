//
//  MZManager.h
//  bailugame
//
//  Created by jkd2972 on 2017/7/26.
//  Copyright © 2017年 egretteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface MZManager : NSObject

@property UIViewController *uiViewController;

+(MZManager*)shareInstance;
-(void)setViewController:(UIViewController*)controller;
-(void)initMZScript:(WKWebViewConfiguration*)webViewConfig scriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler;
-(void)removeMessageHandler:(WKWebViewConfiguration*)webViewConfig;
-(bool)userContentController:(WKUserContentController*)userContentController
     didReceiveScriptMessage:(WKScriptMessage*)message webView:(WKWebView*)webview;
-(void)mzPay;
@end
