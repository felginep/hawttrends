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
@property (nonatomic, retain) UIView * contentView;
@property (nonatomic, retain) HTGridSizeSelector * gridSelector;
@property (nonatomic, retain) UIButton * languageButton;
@property (nonatomic, retain) HTCountryTableViewController * countryTableViewController;
@end

@implementation HTMainViewController

- (void)dealloc {
    [_gridSelector release], _gridSelector = nil;
    [_contentView release], _contentView = nil;
    [super dealloc];
}

- (void)loadView {
    [super loadView];

    _contentView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_contentView];

    _gridSelector = [[HTGridSizeSelector alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 20.0f, 20.0f)];
    _gridSelector.delegate = self;
    [self.view addSubview:_gridSelector];

    _languageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _languageButton.frame = CGRectMake(self.view.frame.size.width - 54.0f, 10.0f, 44.0f, 44.0f);
    _languageButton.backgroundColor = [UIColor redColor];
    [_languageButton addTarget:self action:@selector(toggleLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_languageButton];

    _countryTableViewController = [[HTCountryTableViewController alloc] init];
    _countryTableViewController.countries = [HTTermsDownloader sharedDownloader].countries;
    _countryTableViewController.delegate = self;

    [self _loadInterfaceWithNumberOfRows:HT_NUMBER_CELL andNumberOfColumns:HT_NUMBER_CELL];
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
        [self addChildViewController:_countryTableViewController];
        [self.view addSubview:_countryTableViewController.view];
        _countryTableViewController.view.alpha = 0;
        [UIView animateWithDuration:0.3f animations:^{
            _countryTableViewController.view.alpha = 1.0f;
        }];
    }
}

#pragma mark - HTCountryTableViewControllerDelegate methods

- (void)countryTableViewController:(HTCountryTableViewController *)countryTableViewController didSelectCountry:(NSString *)country {
    [HTTermsDownloader sharedDownloader].currentCountry = country;
    [self _loadInterfaceWithNumberOfRows:2 andNumberOfColumns:2];
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
    [self _loadInterfaceWithNumberOfRows:(position.row + 1) andNumberOfColumns:(position.column + 1)];
}

#pragma mark - Private methods

- (void)_loadInterfaceWithNumberOfRows:(int)numberOfRows andNumberOfColumns:(int)numberOfColumns {
    CGFloat widthCell = _contentView.frame.size.width / numberOfRows;
    CGFloat heightCell = _contentView.frame.size.height / numberOfColumns;

    // Remove all subviews
    [_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGRect frame = CGRectMake(0, 0, widthCell, heightCell);
    for (int row = 0; row < numberOfRows; row++) {
        for (int column = 0; column < numberOfColumns; column++) {
            frame.origin = CGPointMake(row * widthCell, column * heightCell);
            HTCellView * cellView = [[HTCellView alloc] initWithFrame:frame];
            cellView.datasource = self;
            [_contentView addSubview:cellView];
            [cellView release];
        }
    }
}

@end
