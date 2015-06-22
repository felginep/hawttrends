//
//  HTCountryInterfaceController.h
//  HawtTrends
//
//  Created by Pierre Felgines on 22/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@protocol HTPresentationDelegate <NSObject>
- (void)presentedControllerWillDismiss:(WKInterfaceController *)presentedController;
@end

@interface HTCountryInterfaceContext : NSObject
+ (instancetype)contextWithPresentingController:(id<HTPresentationDelegate>)presentingController;
@property (nonatomic, strong) id<HTPresentationDelegate> presentingController;
@end

@interface HTCountryInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceTable * table;

@end
