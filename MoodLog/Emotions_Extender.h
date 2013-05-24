//
//  Emotions_Extender.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Emotions.h"

// Category for modifying Emotions (whose files are automatically generated)
@interface Emotions (Emotions_Category)

- (NSComparisonResult)compare:(Emotions *)otherObject;
- (NSComparisonResult)categoryCompare:(Emotions *)otherObject;
- (NSComparisonResult)reverseCompare:(Emotions *)otherObject;

@end

@interface Emotions_Extender : NSObject
@end
