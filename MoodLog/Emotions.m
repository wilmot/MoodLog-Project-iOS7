//
//  Emotions.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/19/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "Emotions.h"


@implementation Emotions

@dynamic emotionDescription;
@dynamic face;
@dynamic feelValue;
@dynamic hybrid;
@dynamic name;
@dynamic parrotLevel;
@dynamic source;
@dynamic selected;
@dynamic logParent;

- (NSComparisonResult)compare:(Emotions *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSComparisonResult)reverseCompare:(Emotions *)otherObject {
    return [otherObject.name compare:self.name];
}

@end
