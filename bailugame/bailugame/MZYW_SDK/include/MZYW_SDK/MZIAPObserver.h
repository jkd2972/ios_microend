//
//  MZIAPObserver.h
//  MZYW_SDK
//
//  Created by mzyw on 16/9/13.
//  Copyright © 2016年 mzyw. All rights reserved.
//

#ifndef MZIAPObserver_H
#define MZIAPObserver_H

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

@interface MZIAPObserver : NSObject<SKPaymentTransactionObserver>

// 当前支付结果回调
@property (nonatomic, copy) currentPaymentResult currentPaymentResult;
// 补单支付结果回调
@property (nonatomic, copy) lastPaymentResult lastPaymentResult;


/********************* 方法调用 ************************/
/**
 <<实例化交易监测对象>>
 */
+ (MZIAPObserver *)shareStoreObserver;


/**
 <<执行补单操作>>
 参数说明:
 @testModel         是否用测试模式 （YES / NO）
 @lastPaymentResult 补单的回调
 */
- (void)mz_restoreLastNoFinishedPaymentByTestModel:(BOOL)testModel lastPaymentResult:(lastPaymentResult)lastPaymentResult;




@end

#endif

