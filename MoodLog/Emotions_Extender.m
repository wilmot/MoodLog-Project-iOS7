//
//  Emotions_Extender.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "Emotions_Extender.h"
#import "Prefs.h"

@implementation Emotions (Emotions_Category)

- (NSComparisonResult)compare:(Emotions *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSComparisonResult)categoryCompare:(Emotions *)otherObject {
    NSDictionary *moodCategory = @{love: @0, joy: @1, surprise: @2, fear: @3, anger: @4, sadness: @5};
    if ([self.category compare:otherObject.category] == NSOrderedSame) {
        return [self.name compare:otherObject.name]; // Alphabetize within a category
    }
    else {
        return [moodCategory[self.category] compare:moodCategory[otherObject.category]];
    }
}

- (NSComparisonResult)reverseCompare:(Emotions *)otherObject {
    return [otherObject.name compare:self.name];
}

@end

@implementation Emotions_Extender (Emotions)
@end