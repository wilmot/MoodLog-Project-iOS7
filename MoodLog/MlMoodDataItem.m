//
//  MyMoodDataItem.m
//  MoodTracker
//
//  Created by Barry A. Langdon-Lassagne on 9/29/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlMoodDataItem.h"

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

@end
