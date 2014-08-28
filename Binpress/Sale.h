//
//  Sale.h
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sale : NSObject<NSCoding>

@property (nonatomic, assign) NSUInteger componentID;
@property (nonatomic, copy) NSString *componentName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL refunded;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSDate *purchaseDate;
@property (nonatomic, copy) NSString *buyerName;
@property (nonatomic, assign) NSUInteger saleID;
@property (nonatomic, assign) NSUInteger upgradeID;

@end
