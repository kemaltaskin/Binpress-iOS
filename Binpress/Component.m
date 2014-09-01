//
//  Component.m
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import "Component.h"
#import "ComponentManager.h"
#import "Sale.h"

@interface Component () {
    NSMutableDictionary *_sales;
}

@end

@implementation Component

- (instancetype)initWithName:(NSString *)name componentID:(NSUInteger)componentID {
    self = [super init];
    if(self) {
        self.componentName = name;
        self.componentID = componentID;
        
        _sales = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.componentName = [aDecoder decodeObjectForKey:@"componentName"];
        self.componentID = [aDecoder decodeIntegerForKey:@"componentID"];
        id sales = [aDecoder decodeObjectForKey:@"sales"];
        if(sales) {
            _sales = [[NSMutableDictionary alloc] initWithDictionary:sales];
        } else {
            _sales = [[NSMutableDictionary alloc] init];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.componentName forKey:@"componentName"];
    [aCoder encodeInteger:self.componentID forKey:@"componentID"];
    [aCoder encodeObject:_sales forKey:@"sales"];
}

- (void)updateSalesWithResponseObject:(id)responseObject {
    if(![responseObject isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    ComponentManager *cManager = [ComponentManager sharedInstance];
    NSArray *purchases = [responseObject objectForKey:@"purchases"];
    if(purchases.count > 0) {
        for(int i = 0; i < purchases.count; i++) {
            NSDictionary *item = [purchases objectAtIndex:i];
            NSString *saleID = [item objectForKey:@"id"];
            if(![_sales objectForKey:saleID]) {
                NSString *componentID = [item objectForKey:@"component_id"];
                NSString *componentName = [item objectForKey:@"component_name"];
                NSString *title = [item objectForKey:@"title"];
                NSNumber *refunded = [item objectForKey:@"refunded"];
                NSString *amount = [item objectForKey:@"amount"];
                NSString *purchaseDate = [item objectForKey:@"purchased"];
                NSString *buyerName = [item objectForKey:@"buyer"];
                NSString *upgradeID = [item objectForKey:@"upgrade_id"];
                
                Sale *s = [[Sale alloc] init];
                s.saleID = [saleID intValue];
                s.componentID = [componentID integerValue];
                s.componentName = componentName;
                s.title = title;
                s.refunded = [refunded integerValue] == 0 ? NO : YES;
                s.amount = [NSNumber numberWithDouble:[amount doubleValue]];
                s.purchaseDate = [cManager dateForString:purchaseDate];
                if([buyerName isKindOfClass:[NSNull class]]) {
                    s.buyerName = @"Not Available";
                } else {
                    s.buyerName = buyerName;
                }
                if(upgradeID && ![upgradeID isKindOfClass:[NSNull class]]) {
                    s.upgradeID = [upgradeID intValue];
                } else {
                    s.upgradeID = 0;
                }
                [_sales setObject:s forKey:saleID];
            }
        }
    }
}

- (NSArray *)sales {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"refunded = NO"];
    NSArray *sales = [[_sales allValues] filteredArrayUsingPredicate:predicate];
    return [sales sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *d1 = [(Sale *)obj1 purchaseDate];
        NSDate *d2 = [(Sale *)obj2 purchaseDate];
        
        return [d2 compare:d1];
    }];
}

- (NSArray *)refunds {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"refunded = YES"];
    NSArray *refunds = [[_sales allValues] filteredArrayUsingPredicate:predicate];
    return [refunds sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *d1 = [(Sale *)obj1 purchaseDate];
        NSDate *d2 = [(Sale *)obj2 purchaseDate];
        
        return [d2 compare:d1];
    }];
}

- (NSArray *)upgrades {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"upgradeID > 0"];
    NSArray *upgrades = [[_sales allValues] filteredArrayUsingPredicate:predicate];
    return [upgrades sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *d1 = [(Sale *)obj1 purchaseDate];
        NSDate *d2 = [(Sale *)obj2 purchaseDate];
        
        return [d2 compare:d1];
    }];
}

- (NSInteger)numberOfSales {
    NSInteger count = 0;
    for(Sale *s in [_sales allValues]) {
        if(!s.refunded) {
            count++;
        }
    }
    
    return count;
}

- (NSInteger)numberOfRefunds {
    NSInteger count = 0;
    for(Sale *s in [_sales allValues]) {
        if(s.refunded) {
            count++;
        }
    }
    
    return count;
}

- (NSInteger)numberOfUpgrades {
    NSInteger count = 0;
    for(Sale *s in [_sales allValues]) {
        if(s.upgradeID != 0) {
            count++;
        }
    }
    
    return count;
}

- (NSInteger)numberOfSalesThisMonth {
    NSInteger count = 0;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *nowComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:now];
    [nowComponents setHour:0];
    [nowComponents setMinute:0];
    [nowComponents setSecond:0];
    [nowComponents setDay:1];
    
    NSDate *beginningOfCurrentMonth = [calendar dateFromComponents:nowComponents];
    
    NSDateComponents *oneMonth = [[NSDateComponents alloc] init];
    [oneMonth setMonth:1];
    
    NSDate *beginningOfNextMonth = [calendar dateByAddingComponents:oneMonth toDate:beginningOfCurrentMonth options:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"purchaseDate >= %@ AND purchaseDate < %@", beginningOfCurrentMonth, beginningOfNextMonth];
    
    NSArray *sales = [[_sales allValues] filteredArrayUsingPredicate:predicate];
    for(Sale *s in sales) {
        if(!s.refunded) {
            count++;
        }
    }
    
    return count;
}

- (NSInteger)numberOfSalesThisWeek {
    NSInteger count = 0;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *nowComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit fromDate:now];
    [nowComponents setHour:0];
    [nowComponents setMinute:0];
    [nowComponents setSecond:0];
    [nowComponents setWeekday:2];
    
    NSDate *beginningOfWeek = [calendar dateFromComponents:nowComponents];
    
    NSDateComponents *oneWeek = [[NSDateComponents alloc] init];
    [oneWeek setWeekday:1];
    
    NSDate *beginningOfNextWeek = [calendar dateByAddingComponents:oneWeek toDate:beginningOfWeek options:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"purchaseDate >= %@ AND purchaseDate < %@", beginningOfWeek, beginningOfNextWeek];
    
    NSArray *sales = [[_sales allValues] filteredArrayUsingPredicate:predicate];
    for(Sale *s in sales) {
        if(!s.refunded) {
            count++;
        }
    }
    
    return count;
}

- (NSInteger)numberOfSalesToday {
    NSInteger count = 0;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *nowComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit fromDate:now];
    [nowComponents setHour:0];
    [nowComponents setMinute:0];
    [nowComponents setSecond:0];
    
    NSDate *beginningOfToday = [calendar dateFromComponents:nowComponents];
    
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setHour:23];
    [oneDay setMinute:59];
    [oneDay setSecond:59];
    
    NSDate *beginningOfTomorrow = [calendar dateByAddingComponents:oneDay toDate:beginningOfToday options:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"purchaseDate >= %@ AND purchaseDate < %@", beginningOfToday, beginningOfTomorrow];
    
    NSArray *sales = [[_sales allValues] filteredArrayUsingPredicate:predicate];
    for(Sale *s in sales) {
        if(!s.refunded) {
            count++;
        }
    }
    
    return count;
}

- (NSNumber *)revenue {
    double total = 0.0;
    for(Sale *s in [_sales allValues]) {
        if(!s.refunded) {
            total += [s.amount doubleValue];
        }
    }
    
    return [NSNumber numberWithDouble:total];
}

@end
