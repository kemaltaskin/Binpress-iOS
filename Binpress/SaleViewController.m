//
//  SaleViewController.m
//  Binpress
//
//  Created by Kemal Taskin on 22/08/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import "SaleViewController.h"
#import "Sale.h"
#import "ComponentManager.h"

@interface SaleViewController ()

@end

@implementation SaleViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.sale) {
        self.title = self.sale.buyerName;
    }
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
    if(self.sale) {
        return 7;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SaleInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == 0) {
        [cell.textLabel setText:@"Component"];
        [cell.detailTextLabel setText:self.sale.componentName];
    } else if(indexPath.row == 1) {
        [cell.textLabel setText:@"License"];
        [cell.detailTextLabel setText:self.sale.title];
    } else if(indexPath.row == 2) {
        [cell.textLabel setText:@"Buyer"];
        [cell.detailTextLabel setText:self.sale.buyerName];
    } else if(indexPath.row == 3) {
        [cell.textLabel setText:@"Date"];
        NSString *dateString = [NSString stringWithFormat:@"%@", [[ComponentManager sharedInstance] formattedStringForDate:self.sale.purchaseDate]];
        [cell.detailTextLabel setText:dateString];
    } else if(indexPath.row == 4) {
        [cell.textLabel setText:@"Amount"];
        NSString *amountString = [NSString stringWithFormat:@"$%.2f", [self.sale.amount doubleValue]];
        [cell.detailTextLabel setText:amountString];
    } else if(indexPath.row == 5) {
        [cell.textLabel setText:@"Sale ID"];
        NSString *saleIDString = [NSString stringWithFormat:@"%lu", (unsigned long)self.sale.saleID];
        [cell.detailTextLabel setText:saleIDString];
    } else if(indexPath.row == 6) {
        [cell.textLabel setText:@"Upgrade ID"];
        NSString *upgradeIDString = [NSString stringWithFormat:@"%lu", (unsigned long)self.sale.upgradeID];
        [cell.detailTextLabel setText:upgradeIDString];
    } else if(indexPath.row == 67) {
        [cell.textLabel setText:@"Refunded"];
        [cell.detailTextLabel setText:self.sale.refunded ? @"YES" : @"NO"];
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
    
}

@end
