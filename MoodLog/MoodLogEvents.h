//
//  MoodLogEvents.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/13/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Emotions, Stressors;

@interface MoodLogEvents : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber * editing;
@property (nonatomic, retain) NSNumber * energy;
@property (nonatomic, retain) NSString * header;
@property (nonatomic, retain) NSNumber * health;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * journalEntry;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSNumber * mood;
@property (nonatomic, retain) NSNumber * overall;
@property (nonatomic, retain) NSNumber * showFaces;
@property (nonatomic, retain) NSNumber * showFacesEditing;
@property (nonatomic, retain) NSNumber * sleep;
@property (nonatomic, retain) NSNumber * sliderValuesSet;
@property (nonatomic, retain) NSString * sortStyle;
@property (nonatomic, retain) NSString * sortStyleEditing;
@property (nonatomic, retain) NSNumber * stress;
@property (nonatomic, retain) NSNumber * thoughts;
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

- (void)addRelationshipStressorsObject:(Stressors *)value;
- (void)removeRelationshipStressorsObject:(Stressors *)value;
- (void)addRelationshipStressors:(NSSet *)values;
- (void)removeRelationshipStressors:(NSSet *)values;

@end
