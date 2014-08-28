//
//  SalesViewController.m
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import "SalesViewController.h"
#import "SaleViewController.h"
#import "ComponentManager.h"
#import "Component.h"
#import "Sale.h"


@interface SalesViewController ()

@end

@implementation SalesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSInteger count = self.sales.count;
    if(count == 1) {
        self.title = @"1 Object";
    } else {
        self.title = [NSString stringWithFormat:@"%lu Objects", (long)count];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sales.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SaleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Sale *s = [self.sales objectAtIndex:indexPath.row];
    [cell.textLabel setText:s.buyerName];
    [cell.detailTextLabel setText:[[ComponentManager sharedInstance] formattedStringForDate:s.purchaseDate]];
    
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Sale"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Sale *s = [self.sales objectAtIndex:indexPath.row];
        SaleViewController *c = (SaleViewController *)(segue.destinationViewController);
        c.sale = s;
    }
}

@end
