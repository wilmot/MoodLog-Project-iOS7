//
//  Prefs.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface Prefs : NSObject

@end

// Category for modifying UIColors
@interface UIColor (LightAndDark)

- (UIColor *)lighterColor;
- (UIColor *)darkerColor;

@end
