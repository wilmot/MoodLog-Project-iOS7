//
//  MoodLogEvents.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/19/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Emotions;

@interface MoodLogEvents : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber * health;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * journalEntry;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSNumber * sleep;
@property (nonatomic, retain) NSNumber * energy;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) id weather;
@property (nonatomic, retain) NSSet *relationshipEmotions;
@property (nonatomic, retain) NSSet *relationshipStressors;
@end

@interface MoodLogEvents (CoreDataGeneratedAccessors)

- (void)addRelationshipEmotionsObject:(Emotions *)value;
- (void)removeRelationshipEmotionsObject:(Emotions *)value;
- (void)addRelationshipEmotions:(NSSet *)values;
- (void)removeRelationshipEmotions:(NSSet *)values;

- (void)addRelationshipStressorsObject:(NSManagedObject *)value;
- (void)removeRelationshipStressorsObject:(NSManagedObject *)value;
- (void)addRelationshipStressors:(NSSet *)values;
- (void)removeRelationshipStressors:(NSSet *)values;

@end
