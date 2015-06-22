//
//  InterfaceController.h
//  HawtTrends WatchKit Extension
//
//  Created by Pierre on 21/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface HTInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel * mainLabel;
- (IBAction)nextTerm;

@end
