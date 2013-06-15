//
//  HTMainViewController.m
//  HawtTrends
//
//  Created by Pierre Felgines on 23/05/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTMainViewController.h"
#import "HTTermsDownloader.h"

/*
 * Change HT_NUMBER_CELL to split the screen with multiple cells
 */
#define HT_NUMBER_CELL 2.0f

@implementation HTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat widthCell = self.view.frame.size.height / HT_NUMBER_CELL;
    CGFloat heightCell = self.view.frame.size.width / HT_NUMBER_CELL;
    
    CGRect frame = CGRectMake(0, 0, widthCell, heightCell);
    for (int row = 0; row < HT_NUMBER_CELL; row++) {
        for (int column = 0; column < HT_NUMBER_CELL; column++) {
            frame.origin = CGPointMake(column * widthCell, row * heightCell);
            HTCellView * cellView = [[HTCellView alloc] initWithFrame:frame];
            cellView.datasource = self;
            [self.view addSubview:cellView];
            [cellView release];
        }
    }
}

# pragma mark - HTCellViewDatasource

- (NSString *)textToDisplayForCellView:(HTCellView *)cellView {
    NSString * text = [[HTTermsDownloader sharedDownloader] randomTerm];
    if (!text || !text.length) text = @"Loading...";
    return text;
}

@end
