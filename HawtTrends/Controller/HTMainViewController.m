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
#import "OpenInChromeController.h"

@interface HTMainViewController () <HTGridSizeSelectorDelegate, HTCountryTableViewControllerDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) HTGridSizeSelector * gridSelector;
@property (nonatomic, strong) HTCountryTableViewController * countryTableViewController;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic) HTConfiguration currentConfiguration;
@end

@implementation HTMainViewController

- (void)dealloc {
    _gridSelector = nil;
    _countryTableViewController = nil;
    _scrollView = nil;
}

- (void)loadView {
    [super loadView];

    [self _createScrollView];
    [self _createCountryTableView];
    [self _createCollectionView];
    [self _createScrollViewContentSizeConstraints];

    _gridSelector = [[HTGridSizeSelector alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 20.0f, 20.0f)];
    _gridSelector.delegate = self;
    [self.view addSubview:_gridSelector];

    _currentConfiguration = HTConfigurationMake(2, 2);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [_collectionView.collectionViewLayout invalidateLayout];

    if (self.scrollView.contentOffset.x > 0) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
    }
}

#pragma mark - UICollectionViewDataSource methods


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _currentConfiguration.row * _currentConfiguration.column;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HTCollectionViewCell * cell = (HTCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"identifier" forIndexPath:indexPath];
    cell.datasource = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(HTCollectionViewCell *)cell setNeedsAnimating];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HTCollectionViewCell * cell = (HTCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSString * term = cell.textView.animatedText;
    if (term.length) {
        NSURL * callbackURL = [NSURL URLWithString:@"callback://"];
        NSString * searchString = [[term stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/#q=%@", searchString]];
        if ([[OpenInChromeController sharedInstance] isChromeInstalled]) {
            [[OpenInChromeController sharedInstance] openInChrome:url
                                                  withCallbackURL:callbackURL
                                                     createNewTab:YES];
        }
    }
}

#pragma mark - UICollectionViewFlowLayoutDelegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = self.view.bounds.size;
    return CGSizeMake(screenSize.width / _currentConfiguration.row, screenSize.height / _currentConfiguration.column);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.gridSelector.alpha = MAX(0, 1.0f - (scrollView.contentOffset.x / self.collectionView.frame.size.width));
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0) {
        [self.countryTableViewController reloadData];
    }
}

#pragma mark - HTCountryTableViewControllerDelegate methods

- (void)countryTableViewController:(HTCountryTableViewController *)countryTableViewController didSelectCountry:(HTCountry *)country {
    [HTTermsDownloader sharedDownloader].currentCountry = country;
    [self.scrollView scrollRectToVisible:self.collectionView.bounds animated:YES];
    [_collectionView reloadData];
}

# pragma mark - HTCollectionViewCellViewDataSource

- (NSString *)textToDisplayForCellView:(HTCollectionViewCell *)cell {
    NSString * text = [[HTTermsDownloader sharedDownloader] randomTerm];
    if (!text || !text.length) text = @"Loading...";
    return text;
}

#pragma mark - HTGridSizeSelectorDelegate methods

- (void)gridSelector:(HTGridSizeSelector *)gridSelector didChoosePosition:(HTPosition)position {
    _currentConfiguration = HTConfigurationMakeFromPosition(position);
    [_collectionView reloadData];
}

#pragma mark - Private methods

- (void)_createScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];

    // Horizontal
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:NSDictionaryOfVariableBindings(_scrollView)]];

    // Vertical
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:NSDictionaryOfVariableBindings(_scrollView)]];
}

- (void)_createCountryTableView {
    _countryTableViewController = [[HTCountryTableViewController alloc] init];
    _countryTableViewController.delegate = self;
    [self addChildViewController:_countryTableViewController];
    [self.scrollView addSubview:_countryTableViewController.view];

    _countryTableViewController.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_countryTableViewController.view
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0f
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_countryTableViewController.view
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0f
                                                           constant:0]];

    UIView * countryTableView = _countryTableViewController.view;
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[countryTableView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(countryTableView)]];
}

- (void)_createCollectionView {
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_collectionView];


    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0f
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0f
                                                           constant:0]];

    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(_collectionView)]];

    [_collectionView registerClass:[HTCollectionViewCell class] forCellWithReuseIdentifier:@"identifier"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
}

- (void)_createScrollViewContentSizeConstraints {
    UIView * countryTableView = _countryTableViewController.view;
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView][countryTableView]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:NSDictionaryOfVariableBindings(_collectionView, countryTableView)]];
}

@end
