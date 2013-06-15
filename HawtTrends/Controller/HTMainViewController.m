//
//  HTMainViewController.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTMainViewController.h"
#import "HTTermsDownloader.h"

#define HT_NUMBER_CELL 3.0f

@interface HTMainViewController () {
    NSDate * _previousDate;
}

@end

@implementation HTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    CGFloat widthCell = self.view.frame.size.height / HT_NUMBER_CELL;
//    CGFloat heightCell = self.view.frame.size.width / HT_NUMBER_CELL;
//    
//    CGRect frame = CGRectMake(0, 0, widthCell, heightCell);
//    for (int row = 0; row < HT_NUMBER_CELL; row++) {
//        for (int column = 0; column < HT_NUMBER_CELL; column++) {
//            frame.origin = CGPointMake(column * widthCell, row * heightCell);
//            HTCellView * cellView = [[HTCellView alloc] initWithFrame:frame];
//            [self.view addSubview:cellView];
//            [cellView release];
//        }
//    }
    
    HTCellView * cellView = [[HTCellView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    cellView.datasource = self;
    [self.view addSubview:cellView];
    [cellView release];
}

# pragma mark - HTCellViewDatasource

- (NSString *)textToDisplayForCellView:(HTCellView *)cellView {
    return [[HTTermsDownloader sharedDownloader] randomTerm];
}

@end
