//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WechatManager.h"
#import "WechatData.h"
#import "BailuGameView.h"
#import <CommonCrypto/CommonDigest.h>

@interface WechatManager()
{
    BailuGameView* _webview;
}

@end

@implementation WechatManager

static NSString* _newUrl;

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WechatManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WechatManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
//    self.delegate = nil;
//    [super dealloc];
}

- (BOOL)isWXInstalled{
    return [WXApi isWXAppInstalled];
}

- (void)loginWXin:(NSString*)newUrl Handler:(void (^)(NSString *, NSString *))completeHandler{
    _mLoginCompleteHandler = completeHandler;
    _newUrl = newUrl;
    //构造SendAuthReq结构体
    SendAuthReq* req = [[SendAuthReq alloc ] init ];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    bool ret = [WXApi sendReq:req];
    NSLog(@">>> %d", ret);
}

- (void)payWX:(NSString*)value
{
    PayReq* request = [[PayReq alloc] init];
    
    NSLog(@">>> %@", value);
    
    value = [value substringFromIndex:17];
    NSLog(@">>> %@", value);
    NSArray* aArray = [value componentsSeparatedByString:@"&"];
    for (int i = 0; i < aArray.count; i++)
    {
        NSLog(@">>> %d %@", i, [aArray objectAtIndex:i]);
        NSArray *array = [[aArray objectAtIndex:i] componentsSeparatedByString:@"="];
        NSString* key = array[0];
        if ([key isEqualToString:@"prepayid"])
        {
            request.prepayId = array[1];
            NSLog(@">>> prepayId %@", [aArray objectAtIndex:i]);
        }
        else if ([key isEqualToString:@"package"])
        {
            request.package = array[1];
            NSLog(@">>> package %@", [aArray objectAtIndex:i]);
        }
        else if ([key isEqualToString:@"noncestr"])
        {
            request.nonceStr = array[1];
            NSLog(@">>> noncestr %@", [aArray objectAtIndex:i]);
        }
        else if ([key isEqualToString:@"sign"])
        {
            request.sign = array[1];
            NSLog(@">>> sign %@", [aArray objectAtIndex:i]);
        }
    }
    
    request.timeStamp = (unsigned int)[[NSDate date] timeIntervalSince1970];
    NSLog(@">>> timeStamp %d %lf", request.timeStamp, [[NSDate date] timeIntervalSince1970]);
    request.partnerId = @"1900000109";
    
    
    
    int ret = [WXApi sendReq: request];
    NSLog(@">>>>>>>>> %d", ret);
}

- (void)payWXWithPrepayID:(NSString*)prepayId NonceStr:(NSString*)nonceStr Sign:(NSString*)sign
{
    NSLog(@">>> %@", prepayId);
    NSLog(@">>> %@", nonceStr);
    NSLog(@">>> %@", sign);
    
    PayReq* request = [[PayReq alloc] init];
    
    request.partnerId = @PARTNER_ID;
    request.prepayId = prepayId;
    request.package = @"Sign=WXPay";
    request.nonceStr = nonceStr;
    request.timeStamp = (int)[[NSDate date] timeIntervalSince1970];
    request.sign = [self generateSignWithPrepayId:prepayId
                                         NonceStr:nonceStr
                                        TimeStamp:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]]];
    
    int ret = [WXApi sendReq: request];
    NSLog(@">>>>>>>>> pay result %d %d", ret, request.timeStamp);
}

- (void)shareWXWithLink:(NSString*)link Title:(NSString*)title Desc:(NSString*)desc
                  Image:(NSString*)imgUrl Type:(NSString*)type
{
    NSLog(@">>> %@", link);
    NSLog(@">>> %@", title);
    NSLog(@">>> %@", desc);
    NSLog(@">>> %@", imgUrl);
    NSLog(@">>> %@", type);
    
    WXMediaMessage* message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
    [message setThumbImage:image];
    
    WXWebpageObject* webPage = [WXWebpageObject object];
    webPage.webpageUrl = link;
    message.mediaObject = webPage;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    if (type.intValue == 1)
    {
        req.scene = WXSceneSession;
    }
    else
    {
        req.scene = WXSceneTimeline;
    }
    
    [WXApi sendReq:req];
}

- (void)setWebView:(BailuGameView*)webview
{
    _webview = webview;
}

- (NSString*)generateSignWithPrepayId:(NSString*)prepayId NonceStr:(NSString*)nonceStr TimeStamp:(NSString*)timeStamp
{
    NSString* str1 = [NSString stringWithFormat:@"appid=%@&noncestr=%@&package=Sign=WXPay&partnerid=%@&prepayid=%@&timestamp=%@",
                      @APP_ID, nonceStr, @PARTNER_ID, prepayId, timeStamp];
    
    NSLog(@">>>>> %@", str1);
    
    NSString* str2 = [NSString stringWithFormat:@"%@&key=%@", str1, @PAY_KEY];
    
    NSLog(@">>>>> %@", str2);
    
    NSString* str3 = [self MD5:str2];
    
    NSLog(@">>>>> %@", str3);
    
    return str3;
}

- (NSString*)MD5:(NSString*)mdStr
{
    const char* original_str = [mdStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString* hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp
{
    NSLog(@"- (void)onResp:(BaseResp *)resp");
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        NSLog(@">>>--- %@", authResp.code);
        _mLoginCompleteHandler(authResp.code, _newUrl);
    }
    else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *authResp = (PayResp *)resp;
        NSLog(@">>>--- %@", authResp.returnKey);
    }
    else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp* shareResp = (SendMessageToWXResp*)resp;
        NSLog(@">>>--- %d", shareResp.errCode);
        
        if (shareResp.errCode == 0)
        {
            [_webview shareSuccess];
        }
    }
}

- (void)onReq:(BaseReq *)req
{
    NSLog(@"- (void)onReq:(BaseReq *)req");
}

@end
