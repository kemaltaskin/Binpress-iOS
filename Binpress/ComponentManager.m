//
//  ComponentManager.m
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import "ComponentManager.h"
#import "Component.h"
#import "AFHTTPRequestOperationManager.h"
#import <CommonCrypto/CommonDigest.h>

NSString * const ComponentManagerLoadSucceededNotification = @"ComponentManagerLoadSucceededNotification";
NSString * const ComponentManagerLoadFailedNotification = @"ComponentManagerLoadFailedNotification";

@interface ComponentManager () {
    NSMutableDictionary *_componentsDic;
    NSMutableArray *_componentsArray;
    
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_readableDateFormatter;
    
    AFHTTPRequestOperationManager *_requestManager;
}

- (NSString *)md5HexDigest:(NSString *)input;
- (void)fetchSalesForComponent:(Component *)component startPage:(NSUInteger)startPage endPage:(NSUInteger)endPage;
- (NSURL *)appDocumentsDirectory;
- (void)saveComponent:(Component *)component;
- (Component *)loadComponentWithID:(NSUInteger)componentID;

@end

@implementation ComponentManager

+ (instancetype)sharedInstance {
    static ComponentManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ComponentManager alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _componentsDic = [[NSMutableDictionary alloc] init];
        _componentsArray = [[NSMutableArray alloc] init];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzzz"];
        
        _readableDateFormatter = [[NSDateFormatter alloc] init];
        [_readableDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [_readableDateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.binpress.com/api"]];
        _requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    }
    
    return self;
}

- (void)addComponentWithName:(NSString *)name number:(NSUInteger)componentID {
    NSNumber *componentNumber = [NSNumber numberWithInteger:componentID];
    if(![_componentsDic objectForKey:componentNumber]) {
        Component *c = [self loadComponentWithID:componentID];
        if(c == nil) {
            c = [[Component alloc] initWithName:name componentID:componentID];
        }
        
        [_componentsDic setObject:c forKey:componentNumber];
        [_componentsArray addObject:componentNumber];
    }
}

- (NSUInteger)numberOfComponents {
    return [_componentsDic count];
}

- (Component *)componentAtIndex:(NSUInteger)index {
    if(index >= [self numberOfComponents]) {
        return nil;
    }
    
    Component *c = [_componentsDic objectForKey:[_componentsArray objectAtIndex:index]];
    return c;
}

- (NSUInteger)numberOfSales {
    NSUInteger count = 0;
    for(Component *c in [_componentsDic allValues]) {
        count += [c numberOfSales];
    }
    
    return count;
}

- (NSNumber *)totalRevenue {
    double total = 0.0;
    for(Component *c in [_componentsDic allValues]) {
        total += [[c revenue] doubleValue];
    }
    
    return [NSNumber numberWithDouble:total];
}

- (NSDate *)dateForString:(NSString *)dateString {
    return [_dateFormatter dateFromString:dateString];
}

- (NSString *)formattedStringForDate:(NSDate *)date {
    return [_readableDateFormatter stringFromDate:date];
}

- (void)reloadSalesForComponent:(Component *)component {
    NSMutableString *sig = [NSMutableString stringWithFormat:@"%@", self.apiSecret];
    [sig appendFormat:@"apikey=%@", self.apiKey];
    [sig appendFormat:@"&component_id=%lu", (unsigned long)component.componentID];
    [sig appendFormat:@"&page=1"];
    NSString *sigHex = [self md5HexDigest:sig];
    
    NSDictionary *params = @{@"component_id": @(component.componentID), @"page": @"1", @"apikey": self.apiKey, @"sig": sigHex};
    __weak typeof(self) weakSelf = self;
    [_requestManager GET:@"publishers/purchases"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if(![responseObject isKindOfClass:[NSDictionary class]]) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:ComponentManagerLoadFailedNotification object:nil];
                         return;
                     }
                     
                     NSString *total = [responseObject objectForKey:@"total"];
                     if(!total || ![total isKindOfClass:[NSString class]]) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:ComponentManagerLoadFailedNotification object:nil];
                         return;
                     }
                     
                     NSUInteger totalItems = [total intValue];
                     NSUInteger numberOfPages = (totalItems / 10) + ((totalItems % 10) == 0 ? 0 : 1);
                     if(numberOfPages == 1) {
                         [component updateSalesWithResponseObject:responseObject];
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         [strongSelf saveComponent:component];
                         [[NSNotificationCenter defaultCenter] postNotificationName:ComponentManagerLoadSucceededNotification object:nil];
                     } else {
                         [component updateSalesWithResponseObject:responseObject];
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         [strongSelf fetchSalesForComponent:component startPage:2 endPage:numberOfPages];
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:ComponentManagerLoadFailedNotification object:nil];
                 }];
}


#pragma mark -
#pragma mark Private Methods
- (NSString *)md5HexDigest:(NSString *)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    
    return ret;
}

- (NSURL *)appDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

- (void)fetchSalesForComponent:(Component *)component startPage:(NSUInteger)startPage endPage:(NSUInteger)endPage {
    NSMutableString *sig = [NSMutableString stringWithFormat:@"%@", self.apiSecret];
    [sig appendFormat:@"apikey=%@", self.apiKey];
    [sig appendFormat:@"&component_id=%lu", (unsigned long)component.componentID];
    [sig appendFormat:@"&page=%lu", (unsigned long)startPage];
    NSString *sigHex = [self md5HexDigest:sig];
    
    NSDictionary *params = @{@"component_id": @(component.componentID), @"page": @(startPage), @"apikey": self.apiKey, @"sig": sigHex};
    __weak typeof(self) weakSelf = self;
    [_requestManager GET:@"publishers/purchases"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [component updateSalesWithResponseObject:responseObject];
                     if(startPage < endPage) {
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         [strongSelf fetchSalesForComponent:component startPage:(startPage + 1) endPage:endPage];
                     } else {
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         [strongSelf saveComponent:component];
                         [[NSNotificationCenter defaultCenter] postNotificationName:ComponentManagerLoadSucceededNotification object:nil];
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:ComponentManagerLoadFailedNotification object:nil];
                 }];
}

- (void)saveComponent:(Component *)component {
    if(component == nil) {
        return;
    }
    
    NSString *filename = [[self appDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.plist", (unsigned long)component.componentID]];
    [NSKeyedArchiver archiveRootObject:component toFile:filename];
}

- (Component *)loadComponentWithID:(NSUInteger)componentID {
    NSString *filename = [[self appDocumentsDirectory].path stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.plist", (unsigned long)componentID]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return nil;
    }
    
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    if(object == nil || ![object isKindOfClass:[Component class]]) {
        return nil;
    }
    
    return object;
}

@end
