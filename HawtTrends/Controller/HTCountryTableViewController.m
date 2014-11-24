//
//  HTCountryTableViewController.m
//  HawtTrends
//
//  Created by Pierre Felgines on 21/11/2014.
//  Copyright (c) 2014 Pierre Felgines. All rights reserved.
//

#import "HTCountryTableViewController.h"
#import "HTCountryTableViewCell.h"
#import "HTTermsDownloader.h"

@interface HTCountryTableViewController ()

@end

@implementation HTCountryTableViewController

- (void)dealloc {
    _tableView = nil;
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

    NSUInteger index = [[HTTermsDownloader sharedDownloader].countries indexOfObject:[HTTermsDownloader sharedDownloader].currentCountry];
    if (index != NSNotFound) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [HTTermsDownloader sharedDownloader].countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"HTCountryCell";
    HTCountryTableViewCell * cell = (HTCountryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HTCountryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    HTCountry * country = [HTTermsDownloader sharedDownloader].countries[indexPath.row];
    cell.label.text = country.displayName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HTCountry * country = [HTTermsDownloader sharedDownloader].countries[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(countryTableViewController:didSelectCountry:)]) {
        [self.delegate countryTableViewController:self didSelectCountry:country];
    }
}

@end
