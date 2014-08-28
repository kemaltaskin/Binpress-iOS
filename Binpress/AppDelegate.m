//
//  AppDelegate.m
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import "AppDelegate.h"
#import "ComponentManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Account" ofType:@"plist"];
    NSDictionary *account = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    if(account) {
        ComponentManager *cManager = [ComponentManager sharedInstance];
        id apiKey = [account objectForKey:@"APIKey"];
        if(apiKey && [apiKey isKindOfClass:[NSString class]]) {
            [cManager setApiKey:apiKey];
        }
        
        id apiSecret = [account objectForKey:@"APISecret"];
        if(apiSecret && [apiSecret isKindOfClass:[NSString class]]) {
            [cManager setApiSecret:apiSecret];
        }
        
        id publisherName = [account objectForKey:@"Name"];
        if(publisherName && [publisherName isKindOfClass:[NSString class]]) {
            [cManager setPublisherName:publisherName];
        }
        
        id components = [account objectForKey:@"Components"];
        if(components && [components isKindOfClass:[NSArray class]]) {
            for(id component in components) {
                if([component isKindOfClass:[NSDictionary class]]) {
                    NSString *name = [component objectForKey:@"Name"];
                    NSNumber *componentID = [component objectForKey:@"ID"];
                    if(name && componentID) {
                        [cManager addComponentWithName:name number:[componentID integerValue]];
                    }
                }
            }
        }
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
