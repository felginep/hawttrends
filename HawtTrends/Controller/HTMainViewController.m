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

/*
 * Change HT_NUMBER_CELL to split the screen with multiple cells
 */
#define HT_NUMBER_CELL 1

@interface HTMainViewController () <HTGridSizeSelectorDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) HTGridSizeSelector * gridSelector;
@property (nonatomic, retain) UIButton * languageButton;
@property (nonatomic, retain) UIView * overlayView;
@property (nonatomic, retain) UITableView * tableView;
@end

@implementation HTMainViewController

- (void)dealloc {
    [_gridSelector release], _gridSelector = nil;
    [_overlayView release], _overlayView = nil;
    [_tableView release], _tableView = nil;
    [_languageButton release], _languageButton = nil;
    [super dealloc];
}

- (void)loadView {
    [super loadView];

    [self _loadInterfaceWithNumberOfRows:HT_NUMBER_CELL andNumberOfColumns:HT_NUMBER_CELL];

    _gridSelector = [[HTGridSizeSelector alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 20.0f, 20.0f)];
    _gridSelector.delegate = self;
    [self.view addSubview:_gridSelector];

    _overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    _overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    [self.view addSubview:_overlayView];
    _overlayView.alpha = 0;

    _languageButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _languageButton.frame = CGRectMake(self.view.frame.size.width - 54.0f, 10.0f, 44.0f, 44.0f);
    _languageButton.backgroundColor = [UIColor redColor];
    [_languageButton addTarget:self action:@selector(toggleLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_languageButton];

    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(100.0f, 0, 100.0f, 0);
    [self.overlayView addSubview:_tableView];
}

- (void)toggleLanguage:(id)sender {
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [UIView animateWithDuration:0.3f animations:^{
        _overlayView.alpha = ABS(1.0f - _overlayView.alpha);
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [HTTermsDownloader sharedDownloader].languages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"HTLanguageCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }

    cell.textLabel.text = [HTTermsDownloader sharedDownloader].languages[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:40.0f];
    if ([cell.textLabel.text isEqualToString:[HTTermsDownloader sharedDownloader].currentLanguage]) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:40.0f];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [HTTermsDownloader sharedDownloader].currentLanguage = [HTTermsDownloader sharedDownloader].languages[indexPath.row];
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
    CGFloat widthCell = self.view.frame.size.width / numberOfRows;
    CGFloat heightCell = self.view.frame.size.height / numberOfColumns;

    for (UIView * subview in self.view.subviews) {
        if ([subview isKindOfClass:[HTCellView class]]) {
            [subview removeFromSuperview];
        }
    }

    CGRect frame = CGRectMake(0, 0, widthCell, heightCell);
    for (int row = 0; row < numberOfRows; row++) {
        for (int column = 0; column < numberOfColumns; column++) {
            frame.origin = CGPointMake(row * widthCell, column * heightCell);
            HTCellView * cellView = [[HTCellView alloc] initWithFrame:frame];
            cellView.datasource = self;
            [self.view addSubview:cellView];
            [cellView release];
        }
    }

    [self.view bringSubviewToFront:_overlayView];
    [self.view bringSubviewToFront:_gridSelector];
    [self.view bringSubviewToFront:_languageButton];
}

@end
