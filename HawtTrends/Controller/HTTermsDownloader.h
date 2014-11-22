//
//  HTTermsDownloader.h
//  HawtTrends
//
//  Created by Pierre Felgines on 10/06/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTTermsDownloaderDelegate;

@interface HTTermsDownloader : NSObject

@property (nonatomic, strong, readonly) NSArray * terms;
@property (nonatomic, strong) NSString * currentCountry;
@property (nonatomic, weak) id<HTTermsDownloaderDelegate> delegate;

+ (HTTermsDownloader *)sharedDownloader;
- (NSString *)randomTerm;
- (NSArray *)countries;
- (void)downloadTerms;

@end

@protocol HTTermsDownloaderDelegate <NSObject>
@optional
- (void)termsDownloader:(HTTermsDownloader *)termsDownloader didDownloadTerms:(NSArray *)terms;
@end