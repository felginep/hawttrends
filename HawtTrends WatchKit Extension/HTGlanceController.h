//
//  GlanceController.h
//  HawtTrends WatchKit Extension
//
//  Created by Pierre on 21/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface HTGlanceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel * titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel * mainLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel * countryLabel;
@end
