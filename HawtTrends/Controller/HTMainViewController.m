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
@property (nonatomic, retain) NSDictionary * languages;
@property (nonatomic, retain) NSArray * languagesKeys;
@end

@implementation HTMainViewController

- (void)dealloc {
    [_gridSelector release], _gridSelector = nil;
    [_overlayView release], _overlayView = nil;
    [_tableView release], _tableView = nil;
    [_languageButton release], _languageButton = nil;
    [_languages release], _languages = nil;
    [_languagesKeys release], _languagesKeys = nil;
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
    [_languageButton addTarget:self action:@selector(chooseLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_languageButton];

    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(100.0f, 0, 100.0f, 0);
    [self.overlayView addSubview:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _languages = [[NSDictionary alloc] initWithDictionary:@{
                                                           @"Afrique du Sub": @"40",
                                                           @"Allemagne": @"15",
                                                           @"Arabie Saoudite": @"36",
                                                           @"Argentine": @"30",
                                                           @"Australie": @"8",
                                                           @"Autriche": @"44",
                                                           @"Belgique": @"41",
                                                           @"Brésil": @"18",
                                                           @"Canada": @"13",
                                                           @"Chili": @"38",
                                                           @"Colombie": @"32",
                                                           @"Corée du Sud": @"23",
                                                           @"Danemark": @"49",
                                                           @"Egypte": @"29",
                                                           @"Espagne": @"26",
                                                           @"Etats Unis": @"1",
                                                           @"Finlande": @"50",
                                                           @"France": @"16",
                                                           @"Grèce": @"48",
                                                           @"Hong Kong": @"10",
                                                           @"Hongrie": @"45",
                                                           @"Inde": @"3",
                                                           @"Indonésie": @"19",
                                                           @"Israël": @"6",
                                                           @"Italie": @"27",
                                                           @"Japon": @"4",
                                                           @"Kenya": @"37",
                                                           @"Malaisie": @"34",
                                                           @"Mexique": @"21",
                                                           @"Nigeria": @"52",
                                                           @"Norvège": @"51",
                                                           @"Pays-Bas": @"17",
                                                           @"Philippines": @"25",
                                                           @"Pologne": @"31",
                                                           @"Portugal": @"47",
                                                           @"République Tchèque": @"43",
                                                           @"Roumanie": @"39",
                                                           @"Royaume Uni": @"9",
                                                           @"Russie": @"14",
                                                           @"Singapour": @"5",
                                                           @"Suède": @"42",
                                                           @"Suisse": @"46",
                                                           @"Taïwan": @"12",
                                                           @"Thaïlande": @"33",
                                                           @"Turquie": @"24",
                                                           @"Ukraine": @"35",
                                                           @"Vietnam": @"28"
                                                           }] ;

    _languagesKeys = [[[_languages allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
}

- (void)chooseLanguage:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        _overlayView.alpha = ABS(1.0f - _overlayView.alpha);
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _languagesKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"HTLanguageCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }

    cell.textLabel.text = _languagesKeys[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:40.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected");
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

    [self.view bringSubviewToFront:_gridSelector];
    [self.view bringSubviewToFront:_languageButton];
}

@end
