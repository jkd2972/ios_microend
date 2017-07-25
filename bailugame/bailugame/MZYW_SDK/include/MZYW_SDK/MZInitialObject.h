//
//  MZInitialObject.h
//  MZYW_SDK
//
//  Created by mzyw on 16/9/12.
//  Copyright © 2016年 mzyw. All rights reserved.
//

#ifndef MZInitialObject_H
#define MZInitialObject_H

#import <UIKit/UIKit.h>

/**
 <<登录回调>>
 参数说明:
 @ACCOUNT_ID    拇指用户ID
 @LOGIN_ACCOUNT 拇指用户名
 @sign          拇指签名
 */
typedef void(^loginResult)(NSString *ACCOUNT_ID, NSString *LOGIN_ACCOUNT, NSString *sign);

@interface MZInitialObject : NSObject

//登录回调
@property (nonatomic, copy) loginResult loginResult;

/********************* 方法调用 *********************/
/**
 实例化初始化对象
 */
+ (instancetype)shareInitialObject;


/**
 <<执行登录操作>>
 参数说明：
 @gameId             拇指游戏ID
 @packetId           拇指包ID
 @testModel          当前是否用测试模式（YES / NO）
 @loginResult        登录回调
 */
- (void)mz_LoginWithGameId:(NSString *)gameId packetId:(NSString *)packetId testModel:(BOOL)testModel loginResult:(loginResult)loginResult;



@end
#endif
