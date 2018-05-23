//
//  Prefs.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/16/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <Foundation/Foundation.h>
#import "Emotions.h"

typedef enum _ChartFactorType : NSUInteger {
    AllType,
    MoodType,
    StressType,
    EnergyType,
    ThoughtsType,
    HealthType,
    SleepType
} ChartFactorType;

FOUNDATION_EXPORT NSString *const alphabeticalSort;
FOUNDATION_EXPORT NSString *const groupSort;
FOUNDATION_EXPORT NSString *const reverseAlphabeticalSort;
FOUNDATION_EXPORT NSString *const shuffleSort;
FOUNDATION_EXPORT NSString *const love;
FOUNDATION_EXPORT NSString *const joy;
FOUNDATION_EXPORT NSString *const surprise;
FOUNDATION_EXPORT NSString *const fear;
FOUNDATION_EXPORT NSString *const anger;
FOUNDATION_EXPORT NSString *const sadness;
FOUNDATION_EXPORT NSString *const mainCacheName;
extern CGFloat const sliderAlpha;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface Prefs : NSObject

@end

// Category for modifying UIColors
@interface UIColor (LightAndDark)

- (UIColor *)lighterColor;
- (UIColor *)darkerColor;
@end

// Category for modifying Emotions (whose files are automatically generated)
@interface Emotions (Emotions_Category)

- (NSComparisonResult)compare:(Emotions *)otherObject;
- (NSComparisonResult)categoryCompare:(Emotions *)otherObject;
- (NSComparisonResult)reverseCompare:(Emotions *)otherObject;

@end
