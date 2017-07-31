//
//  MZManager.m
//  bailugame
//
//  Created by jkd2972 on 2017/7/26.
//  Copyright © 2017年 egretteam. All rights reserved.
//

#import "MZManager.h"
#import "MZIAPManager.h"
#import "MZInitialObject.h"

#define MH_MZ_BUYWITHID "mz_buyWithId"
#define MH_MZ_LOGIN "mz_login"

#define BUY_KEY_PRODUCT_ID "productId_S"
#define BUY_KEY_CP_SERVER_ID "cpServerId_I"
#define BUY_KEY_CP_ORDER_ID "cpOrderId_S"
#define BUY_KEY_CP_GAME_NAME "cpGameName_S"
#define BUY_KEY_CP_GAME_LEVEL "cpGameLevel_I"
#define BUY_KEY_CP_VERIFY_HOST "cpVerifyHost_S"

#define LOGIN_KEY_GAME_ID "gameId_S"
#define LOGIN_KEY_PACKET_ID "packetId_S"
#define LOGIN_KEY_TEST_MODEL "testModel_I"

@implementation MZManager

static MZManager *_instance;

+(MZManager*)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

-(void)setViewController:(UIViewController*)controller{
    self.uiViewController = controller;
}

-(void)initMZScript:(WKWebViewConfiguration*)webViewConfig
                    scriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler{
    if(webViewConfig==NULL){
        return;
    }
    
    WKWebViewConfiguration * config = webViewConfig;
    
    char * scriptStr =
    "window.mzyw={"
        "mz_buy:function(data){"
            "window.webkit.messageHandlers."MH_MZ_BUYWITHID".postMessage(data);"
        "},"
        "mz_login:function(data){"
            "window.webkit.messageHandlers."MH_MZ_LOGIN".postMessage(data);"
        "}"
    "};";
    
    
    NSString* scriptSource = [NSString stringWithCString:scriptStr encoding:NSUTF8StringEncoding];
    NSLog(@"initMZScript: %@",scriptSource);
    
    WKUserScript* script = [[WKUserScript alloc] initWithSource:scriptSource
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:NO];
    
    [config.userContentController addUserScript:script];
    
    [config.userContentController addScriptMessageHandler:scriptMessageHandler name:@MH_MZ_BUYWITHID];
    [config.userContentController addScriptMessageHandler:scriptMessageHandler name:@MH_MZ_LOGIN];
    
}

-(void)removeMessageHandler:(WKWebViewConfiguration*)webViewConfig{
    if(webViewConfig){
        [webViewConfig.userContentController removeScriptMessageHandlerForName:@MH_MZ_BUYWITHID];
        [webViewConfig.userContentController removeScriptMessageHandlerForName:@MH_MZ_LOGIN];
    }
}

-(bool)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message  webView:(WKWebView*)webview{
    
    if([message.name isEqualToString:@MH_MZ_BUYWITHID]){
        NSString* dataStr = message.body;
        
        NSLog(@">>> mz_buyProductWithProductId: %@", dataStr);
        
        NSData* jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError* err;
        
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&err];
        
        if (err)
        {
            NSLog(@"mz_buyProductWithProductId: json解析失败：%@", err);
            return true;
        }
        

        NSString *productId = [jsonDict objectForKey:@BUY_KEY_PRODUCT_ID];
        NSLog(@"---productId=%@",productId);
        NSInteger serverId = [[jsonDict objectForKey:@BUY_KEY_CP_SERVER_ID] integerValue];
        NSLog(@"---serverId=%li",(long)serverId);
        NSString *orderId = [jsonDict objectForKey:@BUY_KEY_CP_ORDER_ID];
        NSLog(@"---orderId=%@",orderId);
        NSString *gameName = [jsonDict objectForKey:@BUY_KEY_CP_GAME_NAME];
        NSLog(@"---gameName=%@",gameName);
        int gameLevel = [[jsonDict objectForKey:@BUY_KEY_CP_GAME_LEVEL] intValue];
        NSLog(@"---gameLevel=%d",gameLevel);
        NSString *verifyHost = [jsonDict objectForKey:@BUY_KEY_CP_VERIFY_HOST];
        NSLog(@"---verifyHost=%@",verifyHost);
        
//        [[WechatManager sharedManager] payWXWithPrepayID:[jsonDict objectForKey:@"prepayId"]
//                                                NonceStr:[jsonDict objectForKey:@"nonceStr"]
//                                                    Sign:[jsonDict objectForKey:@"sign"]];
        
        // 传入参数，进行购买商品！
        [[MZIAPManager shareStoreManager]
            mz_buyProductWithProductId:@"com.muzhiyouwan.zjjy_60"
            cpServerId:1
            cpOrderId:[NSString stringWithFormat:@"%u", arc4random()]
            cpGameName:@"xxx"
            cpGameLevel:1
            cpVerifyHost:nil
            currentViewCtl:self.uiViewController
            paymentResult:^(NSString *currentPaymentResult, NSString *muzhiOrderId, int payAmount) {
            
            NSLog(@"%@==%@==%d", currentPaymentResult, muzhiOrderId, payAmount);
            if(webview){
                    
                NSString *params = [NSString stringWithFormat:@"{\"result\":\"%@\",\"orderId\":\"%@\",\"amount\":\"%i\"}",currentPaymentResult,muzhiOrderId,payAmount];
                NSString *script = [NSString stringWithFormat:@"window.mzOnPaymentResult(%@)",params];
                    
                [webview evaluateJavaScript:script completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                        
                }];
            }

        }];
    }else if([message.name isEqualToString:@MH_MZ_LOGIN]){
        
        NSString* dataStr = message.body;
        
        NSLog(@">>> mz_login: %@", dataStr);
        
        NSData* jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError* err;
        
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&err];
        
        if (err)
        {
            NSLog(@"mz_login: json解析失败：%@", err);
            return true;
        }

        NSString *gameId = [jsonDict valueForKey:@LOGIN_KEY_GAME_ID];
        NSLog(@"---gameId=%@",gameId);
        NSString *packetId = [jsonDict objectForKey:@LOGIN_KEY_PACKET_ID];
        NSLog(@"---packetId=%@",packetId);
        int testModel =[[jsonDict objectForKey:@LOGIN_KEY_TEST_MODEL] intValue];
        NSLog(@"---testModel=%i",testModel);

        
        
        //调用登录接口
        [[MZInitialObject shareInitialObject] mz_LoginWithGameId:gameId packetId:packetId testModel:(testModel==1?TRUE:FALSE) loginResult:^(NSString *ACCOUNT_ID, NSString *LOGIN_ACCOUNT, NSString *sign) {
            
            NSLog(@"%@==%@==%@", ACCOUNT_ID, LOGIN_ACCOUNT, sign);
            if(webview){
                
                NSString *param = [NSString stringWithFormat:@"{\"account_id\":\"%@\",\"login_account\":\"%@\",\"sign\":\"%@\"}",ACCOUNT_ID,LOGIN_ACCOUNT,sign];
                NSString *script = [NSString stringWithFormat:@"window.mzOnLoginResult(%@)",param];
                
                [webview evaluateJavaScript:script completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                    
                }];
            }
            
        }];
        
        
    }else{
        return false;
    }
    
    return true;
}

-(void)mzPay{
}
@end
