//
//  ComponentViewController.m
//  Binpress
//
//  Created by Kemal Taskin on 22/08/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import "ComponentViewController.h"
#import "SalesViewController.h"
#import "Component.h"
#import "ComponentManager.h"
#import "MBProgressHUD.h"

@interface ComponentViewController ()

@end

@implementation ComponentViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRefreshSucceeded:)
                                                     name:ComponentManagerLoadSucceededNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRefreshFailed:)
                                                     name:ComponentManagerLoadFailedNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.component) {
        self.title = @"Product Details";
    } else {
        self.title = @"No Component";
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if(self.component) {
        [self.nameLabel setText:self.component.componentName];
        [self.totalLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfSales]]];
        [self.refundsLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfRefunds]]];
        [self.upgradesLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfUpgrades]]];
        [self.monthLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfSalesThisMonth]]];
        [self.weekLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfSalesThisWeek]]];
        [self.dayLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfSalesToday]]];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refresh:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Updating";
    
    [[ComponentManager sharedInstance] reloadSalesForComponent:self.component];
}

- (void)onRefreshSucceeded:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.nameLabel setText:self.component.componentName];
    [self.totalLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfSales]]];
    [self.refundsLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfRefunds]]];
    [self.upgradesLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfUpgrades]]];
    [self.monthLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfSalesThisMonth]]];
    [self.weekLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfSalesThisWeek]]];
    [self.dayLabel setText:[NSString stringWithFormat:@"%lu", (long)[self.component numberOfSalesToday]]];
}

- (void)onRefreshFailed:(NSNotification *)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ComponentDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == 0) {
        [cell.textLabel setText:@"All Sales"];
    } else if(indexPath.row == 1) {
        [cell.textLabel setText:@"Refunds"];
    } else if(indexPath.row == 2) {
        [cell.textLabel setText:@"Upgrades"];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Sales"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        SalesViewController *s = (SalesViewController *)(segue.destinationViewController);
        if(indexPath.row == 0) {
            s.title = @"All Sales";
            s.sales = self.component.sales;
        } else if(indexPath.row == 1) {
            s.title = @"Refunds";
            s.sales = self.component.refunds;
        } else if(indexPath.row == 2) {
            s.title = @"Upgrades";
            s.sales = self.component.upgrades;
        }
    }
}

@end
