//
//  Emotions.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/27/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "Emotions.h"
#import "MoodLogEvents.h"


@implementation Emotions

@dynamic category;
@dynamic emotionDescription;
@dynamic feelValue;
@dynamic hybrid;
@dynamic name;
@dynamic parrotLevel;
@dynamic selected;
@dynamic source;
@dynamic x;
@dynamic y;
@dynamic facePath;
@dynamic face;
@dynamic logParent;

- (NSComparisonResult)compare:(Emotions *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSComparisonResult)reverseCompare:(Emotions *)otherObject {
    return [otherObject.name compare:self.name];
}


@end
