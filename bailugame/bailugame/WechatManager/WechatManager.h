//
//  WXApiManager.h
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

//@protocol WXApiManagerDelegate <NSObject>

//@optional
//
//- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)request;
//
//- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)request;
//
//- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)request;
//
//- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response;
//
//- (void)managerDidRecvAuthResponse:(SendAuthResp *)response;
//
//- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response;
//
//- (void)managerDidRecvChooseCardResponse:(WXChooseCardResp *)response;
//
//@end

@class BailuGameView;
@interface WechatManager : NSObject<WXApiDelegate>

//@property (nonatomic, assign) id<WXApiManagerDelegate> delegate;

@property void (^mLoginCompleteHandler)(NSString *, NSString *);

+ (instancetype)sharedManager;

- (void)loginWXin:(NSString*)newUrl Handler:(void (^)(NSString *, NSString *))completeHandler;
- (void)payWX:(NSString*)value;
- (void)payWXWithPrepayID:(NSString*)prepayId NonceStr:(NSString*)nonceStr Sign:(NSString*)sign;
- (void)shareWXWithLink:(NSString*)link Title:(NSString*)title Desc:(NSString*)desc
                  Image:(NSString*)imgUrl Type:(NSString*)type;
- (void)setWebView:(BailuGameView*)webview;

- (BOOL)isWXInstalled;

@end
