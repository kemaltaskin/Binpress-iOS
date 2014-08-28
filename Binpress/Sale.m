//
//  Sale.m
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import "Sale.h"

@implementation Sale

- (instancetype)init {
    self = [super init];
    if(self) {
        
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.componentName = [aDecoder decodeObjectForKey:@"componentName"];
        self.componentID = [aDecoder decodeIntegerForKey:@"componentID"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.refunded = [aDecoder decodeBoolForKey:@"refunded"];
        self.amount = [aDecoder decodeObjectForKey:@"amount"];
        self.purchaseDate = [aDecoder decodeObjectForKey:@"purchaseDate"];
        self.buyerName = [aDecoder decodeObjectForKey:@"buyerName"];
        self.saleID = [aDecoder decodeIntegerForKey:@"saleID"];
        self.upgradeID = [aDecoder decodeIntegerForKey:@"upgradeID"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.componentName forKey:@"componentName"];
    [aCoder encodeInteger:self.componentID forKey:@"componentID"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeBool:self.refunded forKey:@"refunded"];
    [aCoder encodeObject:self.amount forKey:@"amount"];
    [aCoder encodeObject:self.purchaseDate forKey:@"purchaseDate"];
    [aCoder encodeObject:self.buyerName forKey:@"buyerName"];
    [aCoder encodeInteger:self.saleID forKey:@"saleID"];
    [aCoder encodeInteger:self.upgradeID forKey:@"upgradeID"];
}

@end
