//
//  MZIAPManager.h
//  MZYW_SDK
//
//  Created by mzyw on 16/9/13.
//  Copyright © 2016年 mzyw. All rights reserved.
//

#ifndef MZIAPManager_H
#define MZIAPManager_H

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

/**
 <<当前交易支付回调>>
 参数说明:
 @currentPaymentResult 当前交易支付结果
 @muzhiOrderId         拇指订单号
 @payAmount            支付金额
 */
typedef void(^currentPaymentResult)(NSString *currentPaymentResult, NSString *muzhiOrderId, int payAmount);


/**
 <<补单交易支付回调>>
 参数说明:
 @lastPaymentResult 补单交易支付结果
 @muzhiOrderId      拇指订单号
 @payAmount         支付金额
 */
typedef void(^lastPaymentResult)(NSString *lastPaymentResult, NSString *muzhiOrderId, int payAmount);


@interface MZIAPManager : NSObject


//当前支付结果回调
@property (nonatomic, copy) currentPaymentResult currentPaymentResult;
//补单支付结果回调
@property (nonatomic, copy) lastPaymentResult lastPaymentResult;



/********************* 方法调用 ************************/
/**
 <<实例化购买操作对象>>
 */
+ (MZIAPManager*)shareStoreManager;


/**
 <<购买商品操作>>
 参数说明:
 @productId      内购商品ID
 @serverId       cp区服ID
 @cpOrderId      cp订单号
 @cpGameName     cp游戏App名称
 @level          cp游戏角色等级
 @cpVerifyHost   cp回调地址
 @currentViewCtl 当前活跃的控制器
 */
- (void)mz_buyProductWithProductId:(NSString *)productId cpServerId:(NSInteger)cpServerId cpOrderId:(NSString *)cpOrderId cpGameName:(NSString *)cpGameName cpGameLevel:(int)cpGameLevel cpVerifyHost:(NSString *)cpVerifyHost currentViewCtl:(UIViewController *)currentViewCtl paymentResult:(currentPaymentResult)currentPaymentResult;


@end

#endif

