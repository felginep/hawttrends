//
//  WKInterfaceLabel+Performance.h
//  ProtoLyon
//
//  Created by Pierre Felgines on 02/06/2015.
//
//

#import <WatchKit/WatchKit.h>

@interface WKInterfaceLabel (Performance)

- (void)updateFrom:(NSString *)oldValue to:(NSString *)newValue;
- (void)updateAttributedContentFrom:(NSAttributedString *)oldValue to:(NSAttributedString *)newValue;

@end


@interface WKInterfaceImage (Performance)

- (void)updateFrom:(NSString *)oldValue to:(NSString *)newValue;

@end


@protocol WKTableViewModel <NSObject>
@property (nonatomic, strong, readonly) NSArray * rowTypes;
- (id)rowViewModelAtIndex:(NSInteger)index;
- (void)table:(WKInterfaceTable *)table updateFrom:(id)oldViewModel to:(id)newViewModel atIndex:(NSInteger)index;
@end

@interface WKInterfaceTable (Performance)
- (void)updateFrom:(id<WKTableViewModel>)oldValue to:(id<WKTableViewModel>)newValue;
@end