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
#define MH_MZ_LOG "mz_log"

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
        "mz_buyWithId:function(data){"
            "window.webkit.messageHandlers."MH_MZ_BUYWITHID".postMessage(data);"
        "},"
        "mz_login:function(data){"
            "window.webkit.messageHandlers."MH_MZ_LOGIN".postMessage(data);"
        "},"
        "mz_log:function(data){"
            "window.webkit.messageHandlers."MH_MZ_LOG".postMessage(data);"
        "}"
    "};";
    
    
    NSString* scriptSource = [NSString stringWithCString:scriptStr encoding:NSUTF8StringEncoding];
 //   NSLog(@"initMZScript: %@",scriptSource);
    
    WKUserScript* script = [[WKUserScript alloc] initWithSource:scriptSource
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:NO];
    
    [config.userContentController addUserScript:script];
    
    [config.userContentController addScriptMessageHandler:scriptMessageHandler name:@MH_MZ_BUYWITHID];
    [config.userContentController addScriptMessageHandler:scriptMessageHandler name:@MH_MZ_LOGIN];
    [config.userContentController addScriptMessageHandler:scriptMessageHandler name:@MH_MZ_LOG];
    
}

-(void)resetMessageHandler:(WKWebViewConfiguration*)webViewConfig scriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler{
//    if(webViewConfig){
//        [webViewConfig.userContentController addScriptMessageHandler:scriptMessageHandler name:@MH_MZ_BUYWITHID];
//        [webViewConfig.userContentController addScriptMessageHandler:scriptMessageHandler name:@MH_MZ_LOGIN];
//        [webViewConfig.userContentController addScriptMessageHandler:scriptMessageHandler name:@MH_MZ_LOG];
//    }
}

-(void)removeMessageHandler:(WKWebViewConfiguration*)webViewConfig{
//    if(webViewConfig){
//        [webViewConfig.userContentController removeScriptMessageHandlerForName:@MH_MZ_BUYWITHID];
//        [webViewConfig.userContentController removeScriptMessageHandlerForName:@MH_MZ_LOGIN];
//        [webViewConfig.userContentController removeScriptMessageHandlerForName:@MH_MZ_LOG];
//    }
}

static NSDictionary * productDic = nil;

-(NSString *)modifyProductId:(NSString *)productId{
    if(productDic == nil){
        productDic = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"com.mzyw.sansheng_50",@"4" ,//500元宝
                      @"com.mzyw.sansheng_88zs",@"11",//终身
                      @"com.mzyw.sansheng_6",@"12",//100元宝
                      @"com.mzyw.sansheng_18",@"13",//200元宝
                      @"com.mzyw.sansheng_98",@"14",//1000元宝
                      @"com.mzyw.sansheng_198",@"15",//2000元宝
                      @"com.mzyw.sansheng_488",@"16",//5000元宝
                      @"com.mzyw.sansheng_998",@"17",//10000元宝
                      @"com.mzyw.sansheng_1998",@"18",//20000元宝
                      @"com.mzyw.sansheng_30m",@"19",//月卡
                      nil];
    }
    
    return [productDic objectForKey:productId];
}

-(bool)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message  webView:(WKWebView*)webview{
   // NSLog(@"userContentController----");
    if([message.name isEqualToString:@MH_MZ_BUYWITHID]){
        NSDictionary* jsonDict = message.body;
        
    //    NSLog(@">>> mz_buyProductWithProductId: %@", jsonDict);
        
//        NSData* jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSError* err;
//        
//        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                                 options:NSJSONReadingMutableContainers
//                                                                   error:&err];
//        
//        if (err)
//        {
//            NSLog(@"mz_buyProductWithProductId: json解析失败：%@", err);
//            return true;
//        }
        

        NSString *productId = [jsonDict objectForKey:@BUY_KEY_PRODUCT_ID];
        NSString * iapId = [self modifyProductId:productId];
      //  NSLog(@"---productId=%@,iapId=%@ ",productId,iapId);
        NSInteger serverId = [[jsonDict objectForKey:@BUY_KEY_CP_SERVER_ID] integerValue];
      //  NSLog(@"---serverId=%li",(long)serverId);
        NSString *orderId = [jsonDict objectForKey:@BUY_KEY_CP_ORDER_ID];
       // NSLog(@"---orderId=%@",orderId);
        NSString *gameName = [jsonDict objectForKey:@BUY_KEY_CP_GAME_NAME];
       // NSLog(@"---gameName=%@",gameName);
        int gameLevel = [[jsonDict objectForKey:@BUY_KEY_CP_GAME_LEVEL] intValue];
       // NSLog(@"---gameLevel=%d",gameLevel);
        NSString *verifyHost = [jsonDict objectForKey:@BUY_KEY_CP_VERIFY_HOST];
      //  NSLog(@"---verifyHost=%@",verifyHost);
        
        // 传入参数，进行购买商品！
        [[MZIAPManager shareStoreManager]
            mz_buyProductWithProductId:iapId
            cpServerId:serverId
            cpOrderId:orderId
            cpGameName:gameName
            cpGameLevel:gameLevel
            cpVerifyHost:nil
            currentViewCtl:self.uiViewController
            paymentResult:^(NSString *currentPaymentResult, NSString *muzhiOrderId, int payAmount) {
            
          //  NSLog(@"%@==%@==%d", currentPaymentResult, muzhiOrderId, payAmount);
            if(webview){

                NSString *params = [NSString stringWithFormat:@"{\"result\":\"%@\",\"orderId\":\"%@\",\"amount\":\"%i\"}",currentPaymentResult,muzhiOrderId,payAmount];
                NSString *script = [NSString stringWithFormat:@"window.mzOnPaymentResult(%@)",params];
                    
                [webview evaluateJavaScript:script completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                        
                }];
            }

        }];
    }else if([message.name isEqualToString:@MH_MZ_LOGIN]){
        
        NSDictionary * jsonDict = message.body;
        
//        NSLog(@">>> mz_login: %@", dataStr);
//        
//        NSData* jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//        
 //       NSError* err;
//        
//        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                                 options:NSJSONReadingMutableContainers
//                                                                   error:&err];
        
//        if (err)
//        {
//            NSLog(@"mz_login: json解析失败：%@", err);
//            return true;
//        }

        NSString *gameId = [jsonDict valueForKey:@LOGIN_KEY_GAME_ID];
     //   NSLog(@"---gameId=%@",gameId);
        NSString *packetId = [jsonDict objectForKey:@LOGIN_KEY_PACKET_ID];
     //   NSLog(@"---packetId=%@",packetId);
        int testModel =[[jsonDict objectForKey:@LOGIN_KEY_TEST_MODEL] intValue];
     //   NSLog(@"---testModel=%i",testModel);

        
        
        //调用登录接口
        [[MZInitialObject shareInitialObject] mz_LoginWithGameId:@"604" packetId:@"100604001" testModel:FALSE loginResult:^(NSString *ACCOUNT_ID, NSString *LOGIN_ACCOUNT, NSString *sign) {
            
        //    NSLog(@"%@==%@==%@", ACCOUNT_ID, LOGIN_ACCOUNT, sign);
            if(webview){
                
                NSString *param = [NSString stringWithFormat:@"{\"account_id\":\"%@\",\"login_account\":\"%@\",\"sign\":\"%@\"}",ACCOUNT_ID,LOGIN_ACCOUNT,sign];
                NSString *script = [NSString stringWithFormat:@"window.mzOnLoginResult(%@)",param];
                
                [webview evaluateJavaScript:script completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                    
                }];
            }
            
        }];
        
        
    }else if([message.name isEqualToString:@MH_MZ_LOG]){
        NSLog(@"mz_log:%@",message.body);
    }else{
        return false;
    }
    
    return true;
}

-(void)mzPay{
}
@end
