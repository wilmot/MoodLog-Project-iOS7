//
//  MyMoodDataItem.m
//  MoodTracker
//
//  Created by Barry A. Langdon-Lassagne on 9/29/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlMoodDataItem.h"
#import "Prefs.h"

@implementation MlMoodDataItem

-(id)copyWithZone:(NSZone *)zone {
    MlMoodDataItem *copy = [[[self class] allocWithZone:zone] init];
    copy.mood = [self.mood copy];
    copy.category = [self.category copy];
    copy.feelValue = [self.feelValue copy];
    copy.parrotLevel = [self.parrotLevel copy];
    copy.facePath = [self.facePath copy];
    copy.selected = NO;
    return copy;
}

- (NSComparisonResult)compare:(MlMoodDataItem *)otherObject {
    return [self.mood compare:otherObject.mood];
}

- (NSComparisonResult)categoryCompare:(MlMoodDataItem *)otherObject {
    NSDictionary *moodCategory = @{love: @0, joy: @1, surprise: @2, fear: @3, anger: @4, sadness: @5};
    if ([self.category compare:otherObject.category] == NSOrderedSame) {
        return [self.mood compare:otherObject.mood]; // Alphabetize within the category
    }
    else {
        return [moodCategory[self.category] compare:moodCategory[otherObject.category]];
    }
}

- (NSComparisonResult)reverseCompare:(MlMoodDataItem *)otherObject {
    return [otherObject.mood compare:self.mood];
}

- (NSComparisonResult)itemCountCompare:(MlMoodDataItem *)otherObject {
    return [self.itemCount compare:otherObject.itemCount];
}

- (NSComparisonResult)itemCountReverseCompare:(MlMoodDataItem *)otherObject {
    return [otherObject.itemCount compare:self.itemCount];
}


@end
