//
//  Emotions.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MoodLogEvents;

@interface Emotions : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * emotionDescription;
@property (nonatomic, retain) id face;
@property (nonatomic, retain) NSString * facePath;
@property (nonatomic, retain) NSNumber * feelValue;
@property (nonatomic, retain) NSNumber * hybrid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parrotLevel;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) MoodLogEvents *logParent;

@end
