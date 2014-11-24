//
//  HTMainViewController.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTMainViewController.h"
#import "HTTermsDownloader.h"
#import "HTGridSizeSelector.h"
#import "HTCountryTableViewController.h"

/*
 * Change HT_NUMBER_CELL to split the screen with multiple cells
 */
#define HT_NUMBER_CELL 1

@interface HTMainViewController () <HTGridSizeSelectorDelegate, HTCountryTableViewControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) HTGridSizeSelector * gridSelector;
@property (nonatomic, strong) HTCountryTableViewController * countryTableViewController;
@property (nonatomic) HTConfiguration currentConfiguration;
@end

@implementation HTMainViewController

- (void)dealloc {
    _gridSelector = nil;
    _contentView = nil;
    _countryTableViewController = nil;
    _scrollView = nil;
}

- (void)loadView {
    [super loadView];

    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;

    _contentView = [[UIView alloc] initWithFrame:self.view.frame];
    [_scrollView addSubview:_contentView];

    _gridSelector = [[HTGridSizeSelector alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 20.0f, 20.0f)];
    _gridSelector.delegate = self;
    [self.view addSubview:_gridSelector];

    _countryTableViewController = [[HTCountryTableViewController alloc] init];
    _countryTableViewController.delegate = self;
    [self addChildViewController:_countryTableViewController];
    [self.scrollView addSubview:_countryTableViewController.view];

    _currentConfiguration = HTConfigurationMake(2, 2);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 2.0f, self.view.bounds.size.height);
    _contentView.frame = self.view.bounds;
    _countryTableViewController.view.frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);

    [self _loadInterfaceWithConfiguration:_currentConfiguration];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.scrollView.contentOffset.x > 0) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.gridSelector.alpha = MAX(0, 1.0f - (scrollView.contentOffset.x / self.contentView.frame.size.width));
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0) {
        [self.countryTableViewController reloadData];
    }
}

#pragma mark - HTCountryTableViewControllerDelegate methods

- (void)countryTableViewController:(HTCountryTableViewController *)countryTableViewController didSelectCountry:(HTCountry *)country {
    [HTTermsDownloader sharedDownloader].currentCountry = country;
    [self _loadInterfaceWithConfiguration:_currentConfiguration];
    [self.scrollView scrollRectToVisible:self.contentView.bounds animated:YES];
}

# pragma mark - HTCellViewDatasource

- (NSString *)textToDisplayForCellView:(HTCellView *)cellView {
    NSString * text = [[HTTermsDownloader sharedDownloader] randomTerm];
    if (!text || !text.length) text = @"Loading...";
    return text;
}

#pragma mark - HTGridSizeSelectorDelegate methods

- (void)gridSelector:(HTGridSizeSelector *)gridSelector didChoosePosition:(HTPosition)position {
    _currentConfiguration = HTConfigurationMakeFromPosition(position);
    [self _loadInterfaceWithConfiguration:_currentConfiguration];
}

#pragma mark - Private methods

- (void)_loadInterfaceWithConfiguration:(HTConfiguration)configuration {
    CGFloat widthCell = _contentView.frame.size.width / configuration.row;
    CGFloat heightCell = _contentView.frame.size.height / configuration.column;

    // Remove all subviews
    [_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGRect frame = CGRectMake(0, 0, widthCell, heightCell);
    for (int row = 0; row < configuration.row; row++) {
        for (int column = 0; column < configuration.column; column++) {
            frame.origin = CGPointMake(row * widthCell, column * heightCell);
            HTCellView * cellView = [[HTCellView alloc] initWithFrame:frame];
            cellView.datasource = self;
            [_contentView addSubview:cellView];
        }
    }
}

@end
