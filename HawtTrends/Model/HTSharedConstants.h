//
//  HTSharedConstants.h
//  HawtTrends
//
//  Created by Pierre on 21/06/2015.
//  Copyright (c) 2015 Pierre Felgines. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kHTWatchAction;
extern NSString * const kHTWatchResponse;
extern NSString * const kHTWatchUserInfos;

typedef NS_ENUM(NSUInteger, HTWatchAction) {
    HTWatchActionSavedTerms,
    HTWatchActionFetchTerms,
    HTWatchActionCurrentCountry,
    HTWatchActionCountries,
    HTWatchActionSetCurrentCountry
};