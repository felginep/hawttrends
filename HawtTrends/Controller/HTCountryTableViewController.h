//
//  HTCountryTableViewController.h
//  HawtTrends
//
//  Created by Pierre Felgines on 21/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTCountryTableViewController;
@protocol HTCountryTableViewControllerDelegate <NSObject>
- (void)countryTableViewController:(HTCountryTableViewController *)countryTableViewController didSelectCountry:(NSString *)country;
@end

@interface HTCountryTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray * countries;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, assign) id<HTCountryTableViewControllerDelegate> delegate;
@end
