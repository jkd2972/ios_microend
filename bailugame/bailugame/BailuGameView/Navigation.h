//
//  Navigation.h
//  bailugame
//
//  Created by lijian on 6/15/17.
//  Copyright © 2017 egretteam. All rights reserved.
//

#ifndef Navigation_h
#define Navigation_h

static const int NavigationHeight = 64;
static const int NavigationOffset = 24;

#import <UIKit/UIKit.h>

@class BailuGameView;
@interface Navigation : NSObject


- (instancetype)initWithSuperView:(UIView*)superView WebView:(BailuGameView*)webview;
+ (Navigation*)getInstance;
- (void)setTitle:(NSString*)str;
- (void)setCurrentUrl:(NSString*)url;

@end

#endif /* Navigation_h */
