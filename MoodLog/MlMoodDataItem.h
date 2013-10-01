//
//  MlMoodDataItem.h
//  MoodTracker
//
//  Created by Barry A. Langdon-Lassagne on 9/29/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MlMoodDataItem : NSObject

@property (nonatomic, retain) NSString *mood;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSNumber *feelValue;
@property (nonatomic, retain) NSNumber *parrotLevel;
@property (nonatomic, retain) NSString *facePath;
@property (nonatomic, assign) BOOL selected;

@end
