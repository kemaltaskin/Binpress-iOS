//
//  ComponentManager.h
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ComponentManagerLoadSucceededNotification;
extern NSString * const ComponentManagerLoadFailedNotification;

@class Component;

@interface ComponentManager : NSObject

@property (nonatomic, copy) NSString *apiKey;
@property (nonatomic, copy) NSString *apiSecret;
@property (nonatomic, copy) NSString *publisherName;

+ (instancetype)sharedInstance;

- (void)addComponentWithName:(NSString *)name number:(NSUInteger)componentID;

- (NSUInteger)numberOfComponents;
- (Component *)componentAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfSales;
- (NSNumber *)totalRevenue;

- (NSDate *)dateForString:(NSString *)dateString;
- (NSString *)formattedStringForDate:(NSDate *)date;

- (void)reloadSalesForComponent:(Component *)component;

@end
