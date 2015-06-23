//
//  WKInterface+Performance.m
//  ProtoLyon
//
//  Created by Pierre Felgines on 02/06/2015.
//
//

#import "WKInterface+Performance.h"

@implementation WKInterfaceLabel (Performance)

- (void)updateFrom:(NSString *)oldValue to:(NSString *)newValue {
    if (![newValue isEqualToString:oldValue]) {
        if (newValue) {
            [self setHidden:NO];
            [self setText:newValue];

//            NSLog(@"[WKInterfaceLabel] Update from %@ to %@", oldValue, newValue);
        } else {
            [self setHidden:YES];
        }
    }
}

- (void)updateAttributedContentFrom:(NSAttributedString *)oldValue to:(NSAttributedString *)newValue {
    if (![newValue isEqualToAttributedString:oldValue]) {
        if (newValue) {
            [self setHidden:NO];
            [self setAttributedText:newValue];

//            NSLog(@"[WKInterfaceLabel attr] Update from %@ to %@", [oldValue string], [newValue string]);
        } else {
            [self setHidden:YES];
        }
    }
}

@end


@implementation WKInterfaceImage (Performance)

- (void)updateFrom:(NSString *)oldValue to:(NSString *)newValue {
    if (![newValue isEqualToString:oldValue]) {
        [self setImageNamed:newValue];
//        NSLog(@"[WKInterfaceImage] Update from %@ to %@", oldValue, newValue);
    }
}

@end

@implementation WKInterfaceTable (Performance)

- (void)updateFrom:(id<WKTableViewModel>)oldValue to:(id<WKTableViewModel>)newValue {
    if (oldValue && newValue) {
        // only update if necessary
        if (oldValue.rowTypes.count == 0) {
            [self setRowTypes:newValue.rowTypes];
        } else if (newValue.rowTypes.count != oldValue.rowTypes.count) {
            // swap old row types for new row types
            [newValue.rowTypes enumerateObjectsUsingBlock:^(NSString * newRowType, NSUInteger index, BOOL *stop) {
                BOOL swap = true;
                if (index < oldValue.rowTypes.count) {
                    NSString * oldRowType = oldValue.rowTypes[index];
                    if ([oldRowType isEqualToString:newRowType]) {
                        swap = false;
                    } else {
                        [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index]];
                    }
                }
                if (swap) {
                    [self insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withRowType:newRowType];
                }
            }];

            NSInteger range = oldValue.rowTypes.count - newValue.rowTypes.count;
            if (range > 0) {
                [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newValue.rowTypes.count, range)]];
            }
        }

        // Update every row
        for (int i = 0; i < self.numberOfRows; i++) {
            id oldRowViewModel = [oldValue rowViewModelAtIndex:i];
            id newRowViewModel = [newValue rowViewModelAtIndex:i];
            [newValue table:self updateFrom:oldRowViewModel to:newRowViewModel atIndex:i];
        }
    } else if (newValue) {
        // Set row types
        [self setRowTypes:newValue.rowTypes];
        // Update every row
        for (int i = 0; i < self.numberOfRows; i++) {
            id rowViewModel = [newValue rowViewModelAtIndex:i];
            [newValue table:self updateFrom:nil to:rowViewModel atIndex:i];
        }
    }
}

@end