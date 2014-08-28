//
//  ComponentsViewController.h
//  Binpress
//
//  Created by Kemal Taskin on 6/26/14.
//  Copyright (c) 2014 Yakamoz Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComponentsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UILabel *publisherNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *revenueLabel;
@property (nonatomic, strong) IBOutlet UILabel *salesLabel;

@end
