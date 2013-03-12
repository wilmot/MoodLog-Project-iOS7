//
//  Emotions.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "Emotions.h"
#import "MoodLogEvents.h"
#import "Prefs.h"


@implementation Emotions

@dynamic category;
@dynamic emotionDescription;
@dynamic face;
@dynamic facePath;
@dynamic feelValue;
@dynamic hybrid;
@dynamic name;
@dynamic parrotLevel;
@dynamic selected;
@dynamic source;
@dynamic x;
@dynamic y;
@dynamic logParent;


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
