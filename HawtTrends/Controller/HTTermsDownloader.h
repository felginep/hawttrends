//
//  HTTermsDownloader.h
//  HawtTrends
//
//  Created by Pierre Felgines on 10/06/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCountry.h"

static NSString * kTermsDownloadedNotification = @"kTermsDownloadedNotification";

@protocol HTTermsDownloaderDelegate;

@interface HTTermsDownloader : NSObject

@property (nonatomic, strong, readonly) NSArray * terms;
@property (nonatomic, strong) HTCountry * currentCountry;
@property (nonatomic, strong) NSArray * countries;
@property (nonatomic, weak) id<HTTermsDownloaderDelegate> delegate;

+ (HTTermsDownloader *)sharedDownloader;
- (NSString *)randomTerm;
- (void)downloadTerms;
- (CGFloat)fontSizeForSize:(CGSize)size;

@end

@protocol HTTermsDownloaderDelegate <NSObject>
@optional
- (void)termsDownloader:(HTTermsDownloader *)termsDownloader didDownloadTerms:(NSArray *)terms;
@end