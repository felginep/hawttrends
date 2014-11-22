//
//  HTCountryTableViewController.m
//  HawtTrends
//
//  Created by Pierre Felgines on 21/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTCountryTableViewController.h"
#import "HTCountryTableViewCell.h"

@interface HTCountryTableViewController ()

@end

@implementation HTCountryTableViewController

- (void)dealloc {
    _tableView = nil;
    _countries = nil;
    _country = nil;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor colorWithRed:0.952f green:0.710f blue:0 alpha:1.0f];

    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _tableView.contentInset = UIEdgeInsetsMake(self.view.frame.size.height / 2.0f - 40.0f, 0, self.view.frame.size.height / 2.0f - 40.0f, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    [self.tableView reloadData];

    if (self.country) {
        NSUInteger index = [self.countries indexOfObject:self.country];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"HTLanguageCell";
    HTCountryTableViewCell * cell = (HTCountryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HTCountryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.label.text = self.countries[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(countryTableViewController:didSelectCountry:)]) {
        [self.delegate countryTableViewController:self didSelectCountry:self.countries[indexPath.row]];
    }
}

@end
