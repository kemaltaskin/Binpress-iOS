//
//  Component.h
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Component : NSObject<NSCoding>

@property (nonatomic, assign) NSUInteger componentID;
@property (nonatomic, copy) NSString *componentName;

- (instancetype)initWithName:(NSString *)name componentID:(NSUInteger)componentID;

- (void)updateSalesWithResponseObject:(id)responseObject;
- (NSArray *)sales;
- (NSArray *)refunds;
- (NSArray *)upgrades;

- (NSInteger)numberOfSales;
- (NSInteger)numberOfRefunds;
- (NSInteger)numberOfUpgrades;
- (NSInteger)numberOfSalesThisMonth;
- (NSInteger)numberOfSalesThisWeek;
- (NSInteger)numberOfSalesToday;

- (NSNumber *)revenue;

@end
