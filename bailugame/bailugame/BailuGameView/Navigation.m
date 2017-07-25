//
//  Navigation.m
//  bailugame
//
//  Created by lijian on 6/15/17.
//  Copyright © 2017 egretteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Navigation.h"
#import "BailuGameView.h"

@interface Navigation ()
{
    UIView* _superView;
    UIView* _uiView;
    
    UILabel* _titleView;
    
    UIButton* _shareBtn;
    UIButton* _reloadBtn;
    UIButton* _backBtn;
    
    BailuGameView* _webview;
}

@end

static Navigation* _instance;

@implementation Navigation

- (instancetype)initWithSuperView:(UIView*)superView WebView:(BailuGameView*)webview;
{
    if (self = [super init]) {
        _superView = superView;
        [self createView];
        _instance = self;
        _webview = webview;
    }
    
    return self;
}

+ (Navigation*)getInstance
{
    return _instance;
}

- (void)setTitle:(NSString*)str
{
    [_titleView setText:str];
}

- (void)setCurrentUrl:(NSString*)url
{
    if ([url rangeOfString:@"http://wan.yichi666.com/go.php"].location != NSNotFound
        || [url rangeOfString:@"http://wan.yichi666.com/games"].location != NSNotFound
        || [url rangeOfString:@"http://wan.yichi666.com/activity"].location != NSNotFound
        || [url rangeOfString:@"http://wan.yichi666.com/mine"].location != NSNotFound
        || [url rangeOfString:@"http://wan.yichi666.com/FreeGame"].location != NSNotFound)
    {
        _backBtn.hidden = true;
    }
    else
    {
        _backBtn.hidden = false;
    }
}

- (void)createView
{
    const int height = NavigationHeight - NavigationOffset;
    const int btnSize = 32;
    UIColor* btnColor = [UIColor blackColor];
    
    CGRect superBound = [UIScreen mainScreen].bounds;
    _uiView = [[UIView alloc] initWithFrame:CGRectMake(superBound.origin.x, superBound.origin.y + NavigationOffset,
                                                       superBound.size.width, height)];
    [_uiView setBackgroundColor:[UIColor blackColor]];
    [_superView addSubview:_uiView];
    
    _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                           superBound.size.width, height)];
    [_titleView setText:@""];
    [_titleView setBackgroundColor:[UIColor blackColor]];
    [_titleView setTextColor:[UIColor whiteColor]];
    [_titleView setTextAlignment:NSTextAlignmentCenter];
    _titleView.font = [UIFont systemFontOfSize:20];
    [_uiView addSubview:_titleView];
    
    UIImage* shareImg = [UIImage imageNamed:@"share.png"];
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(superBound.size.width - height + (height - btnSize) / 2,
                                                           (height - btnSize) / 2,
                                                           btnSize, btnSize)];
    [_shareBtn setBackgroundColor:btnColor];
    [_shareBtn setBackgroundImage:shareImg forState:UIControlStateNormal];
    [_uiView addSubview:_shareBtn];
    
    UIImage* reloadImg = [UIImage imageNamed:@"reload.png"];
    _reloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(superBound.size.width - height * 2 + (height - btnSize) / 2,
                                                            (height - btnSize) / 2,
                                                            btnSize, btnSize)];
    [_reloadBtn setBackgroundColor:btnColor];
    [_reloadBtn setBackgroundImage:reloadImg forState:UIControlStateNormal];
    [_uiView addSubview:_reloadBtn];
    
    UIImage* backImg = [UIImage imageNamed:@"back.png"];
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake((height - btnSize) / 2, (height - btnSize) / 2,
                                                          btnSize, btnSize)];
    [_backBtn setBackgroundColor:btnColor];
    [_backBtn setBackgroundImage:backImg forState:UIControlStateNormal];
    [_uiView addSubview:_backBtn];
    
    [_shareBtn addTarget:self action:@selector(shareBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_reloadBtn addTarget:self action:@selector(reloadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _backBtn.hidden = true;
}

- (void)backBtnClicked
{
    [_webview goBack];
}

- (void)reloadBtnClicked
{
    [_webview reload];
}

- (void)shareBtnClicked
{
    [_webview share];
}

@end
