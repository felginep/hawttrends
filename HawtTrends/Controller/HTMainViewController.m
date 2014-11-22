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

@interface HTMainViewController () <HTGridSizeSelectorDelegate, HTCountryTableViewControllerDelegate>
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) HTGridSizeSelector * gridSelector;
@property (nonatomic, strong) UIButton * languageButton;
@property (nonatomic, strong) HTCountryTableViewController * countryTableViewController;
@property (nonatomic) HTConfiguration currentConfiguration;
@end

@implementation HTMainViewController

- (void)dealloc {
    _gridSelector = nil;
    _contentView = nil;
}

- (void)loadView {
    [super loadView];

    _contentView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_contentView];

    _gridSelector = [[HTGridSizeSelector alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 20.0f, 20.0f)];
    _gridSelector.delegate = self;
    [self.view addSubview:_gridSelector];

    _languageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _languageButton.frame = CGRectMake(self.view.frame.size.width - 54.0f, 10.0f, 44.0f, 44.0f);
    _languageButton.backgroundColor = [UIColor redColor];
    [_languageButton addTarget:self action:@selector(toggleLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_languageButton];

    _countryTableViewController = [[HTCountryTableViewController alloc] init];
    _countryTableViewController.countries = [HTTermsDownloader sharedDownloader].countries;
    _countryTableViewController.delegate = self;

    _currentConfiguration = HTConfigurationMake(2, 2);
    [self _loadInterfaceWithConfiguration:_currentConfiguration];
}

- (void)toggleLanguage:(id)sender {
    if (_countryTableViewController.parentViewController == self) {
        [UIView animateWithDuration:0.3f animations:^{
            _countryTableViewController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [_countryTableViewController.view removeFromSuperview];
            [_countryTableViewController removeFromParentViewController];
        }];
    } else {
        _countryTableViewController.country = [HTTermsDownloader sharedDownloader].currentCountry;
        [self addChildViewController:_countryTableViewController];
        [self.view addSubview:_countryTableViewController.view];
        [self.view bringSubviewToFront:_languageButton];
        _countryTableViewController.view.alpha = 0;
        [UIView animateWithDuration:0.3f animations:^{
            _countryTableViewController.view.alpha = 1.0f;
        }];
    }
}

#pragma mark - HTCountryTableViewControllerDelegate methods

- (void)countryTableViewController:(HTCountryTableViewController *)countryTableViewController didSelectCountry:(NSString *)country {
    [HTTermsDownloader sharedDownloader].currentCountry = country;
    [self _loadInterfaceWithConfiguration:_currentConfiguration];
    [self toggleLanguage:nil];
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
