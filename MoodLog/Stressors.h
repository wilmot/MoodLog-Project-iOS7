//
//  Stressors.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/19/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MoodLogEvents;

@interface Stressors : NSManagedObject

@property (nonatomic, retain) NSNumber * defaultValue;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * strength;
@property (nonatomic, retain) NSString * stressorDescription;
@property (nonatomic, retain) MoodLogEvents *logParent2;

@end
