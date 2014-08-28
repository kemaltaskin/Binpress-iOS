//
//  ComponentsViewController.m
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import "ComponentsViewController.h"
#import "ComponentViewController.h"
#import "ComponentManager.h"
#import "Component.h"

@interface ComponentsViewController ()

@end

@implementation ComponentsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRefreshSucceeded:)
                                                     name:ComponentManagerLoadSucceededNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Products";
    
    ComponentManager *cManager = [ComponentManager sharedInstance];
    NSString *publisherName = cManager.publisherName;
    if(publisherName && [publisherName length] > 0) {
        [self.publisherNameLabel setText:publisherName];
    } else {
        [self.publisherNameLabel setText:@"Publisher Name"];
    }
    
    [self.salesLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[cManager numberOfSales]]];
    [self.revenueLabel setText:[NSString stringWithFormat:@"$%.2f", [[cManager totalRevenue] doubleValue]]];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        [navBar setBarTintColor:[UIColor colorWithRed:0.0667 green:0.4471 blue:0.7765 alpha:1.0]];
        [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
        [navBar setTintColor:[UIColor whiteColor]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        [navBar setTintColor:[UIColor colorWithRed:0.0667 green:0.4471 blue:0.7765 alpha:1.0]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)onRefreshSucceeded:(NSNotification *)notification
{
    ComponentManager *cManager = [ComponentManager sharedInstance];
    [self.salesLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[cManager numberOfSales]]];
    [self.revenueLabel setText:[NSString stringWithFormat:@"$%.2f", [[cManager totalRevenue] doubleValue]]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[ComponentManager sharedInstance] numberOfComponents];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ComponentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Component *c = [[ComponentManager sharedInstance] componentAtIndex:indexPath.row];
    if(c) {
        [[cell textLabel] setText:c.componentName];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Component"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Component *c = [[ComponentManager sharedInstance] componentAtIndex:indexPath.row];
        ComponentViewController *s = (ComponentViewController *)(segue.destinationViewController);
        s.component = c;
    }
}

@end
