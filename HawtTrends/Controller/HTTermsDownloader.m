//
//  HTTermsDownloader.m
//  HawtTrends
//
//  Created by Pierre Felgines on 10/06/13.
//  Copyright (c) 2013 Pierre Felgines. All rights reserved.
//

#import "HTTermsDownloader.h"

#define HT_TERMS_API_URL @"http://hawttrends.appspot.com/api/terms/"


@implementation HTTermsDownloader

+ (HTTermsDownloader *)sharedDownloader {
    static HTTermsDownloader * sSharedDownloader = nil;
    if (!sSharedDownloader) {
        sSharedDownloader = [[HTTermsDownloader alloc] init];
    }
    return sSharedDownloader;
}

- (NSString *)randomTerm {
    NSUInteger index = (int)(((float)rand() / (float)RAND_MAX) * self.terms.count);
    return self.terms[index];
}

- (void)downloadTerms {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error = nil;
        NSString * jsonString = [NSString stringWithContentsOfURL:[NSURL URLWithString:HT_TERMS_API_URL] encoding:NSUTF8StringEncoding error:&error];
        if (error) NSLog(@"ERROR : %@", error.description);
        
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (error) NSLog(@"ERROR : %@", error.description);
        
        [_terms release];
        _terms = [[json objectForKey:@"1"] retain];
    });
}

@end
