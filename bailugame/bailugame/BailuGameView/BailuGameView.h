//
//  BailuGameView.h
//  bailugame
//
//  Created by 闫佳奇 on 17/3/17.
//  Copyright © 2017年 egretteam. All rights reserved.
//

#ifndef BailuGameView_h
#define BailuGameView_h


#endif /* BailuGameView_h */


#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface  BailuGameView : NSObject  <WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property WKWebView *mWebView;
@property UIView *mSuperView;

-(instancetype)initWithSuperView:(UIView *)superView;
-(void)removeMessageHandler;

- (void)goBack;
- (void)reload;
- (void)share;
- (void)shareSuccess;

@end
