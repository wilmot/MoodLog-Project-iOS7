//
//  Prefs.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "Prefs.h"

 NSString *const alphabeticalSort = @"Alphabetical";
 NSString *const groupSort = @"Group";
 NSString *const reverseAlphabeticalSort = @"Reverse Alphabetical";
 NSString *const shuffleSort = @"Shuffle";
 NSString *const love = @"Love";
 NSString *const joy = @"Joy";
 NSString *const surprise = @"Surprise";
 NSString *const fear = @"Fear";
 NSString *const anger = @"Anger";
 NSString *const sadness = @"Sadness";

// Category for extending Emotions class (which is auto-generated)
@implementation Emotions (Emotions_Category)

- (NSComparisonResult)compare:(Emotions *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSComparisonResult)categoryCompare:(Emotions *)otherObject {
    NSDictionary *moodCategory = @{love: @0, joy: @1, surprise: @2, fear: @3, anger: @4, sadness: @5};
    if ([self.category compare:otherObject.category] == NSOrderedSame) {
        return [self.name compare:otherObject.name]; // Alphabetize within the category
    }
    else {
        return [moodCategory[self.category] compare:moodCategory[otherObject.category]];
    }
}

- (NSComparisonResult)reverseCompare:(Emotions *)otherObject {
    return [otherObject.name compare:self.name];
}

@end

// Category for modifying UIColors
@implementation UIColor (LightAndDark)

- (UIColor *)lighterColor
{
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * 1.1, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    float h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.9
                               alpha:a];
    return nil;
}
@end


// Notes:
// When the button image is the wrong size (this looks like a bug), try adding and deleting a title. This seemed to fix it in at least one case

@implementation Prefs

@end
