//
//  ComponentViewController.h
//  Binpress
//
//  Created by Kemal Taskin on 22/08/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Component;

@interface ComponentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) Component *component;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalLabel;
@property (nonatomic, strong) IBOutlet UILabel *refundsLabel;
@property (nonatomic, strong) IBOutlet UILabel *upgradesLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *weekLabel;
@property (nonatomic, strong) IBOutlet UILabel *dayLabel;


- (IBAction)refresh:(id)sender;

@end
