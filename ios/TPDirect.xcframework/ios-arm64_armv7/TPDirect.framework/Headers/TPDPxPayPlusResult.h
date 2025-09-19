//
//  TPDPxPayPlusResult.h
//  TPDirect
//
//  Created by Kevin Kao on 2025/4/15.
//  Copyright © 2025 tech.cherri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPDPxPayPlusResult : NSObject
@property (strong, nonatomic) NSString * recTradeId;
@property (strong, nonatomic) NSString * orderNumber;
@property (assign, nonatomic) NSInteger  status;
@property (strong, nonatomic) NSString * bankTransactionId;

@end
