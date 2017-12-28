//
//  MoodLog_Tests.m
//  MoodLog Tests
//
//  Created by Barry Langdon-Lassagne on 9/20/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <XCTest/XCTest.h>
#import "MlAppDelegate.h"
#import "MlMoodDataItem.h"
#import "Emotions.h"

@interface MoodLog_Tests : XCTestCase <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MoodLog_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testmoodListDictionary {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    NSLog(@"BadgeCount: %ld", (long)delegate.badgeCount);
    NSLog(@"Dictionary count: %lu", (unsigned long)delegate.moodListDictionary.count);
    if ([delegate.moodListDictionary count] == 0) {
        XCTFail(@"The Mood List Dictionary is empty.");
    }
    if ([delegate.moodListDictionary count] < 140) {
        XCTFail(@"The Mood List Dictionary seems to be missing entries. Dictionary: \n%@", delegate.moodListDictionary);
    }
}

- (void)testEmotionsFromPList {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    NSLog(@"Dictionary count: %lu", (unsigned long)delegate.emotionsFromPList.count);
    if ([delegate.emotionsFromPList count] == 0) {
        XCTFail(@"The Mood List Dictionary is empty.");
    }
    if ([delegate.emotionsFromPList count] < 140) {
        XCTFail(@"The list of emotions generated from the property list seems to be missing entries. Dictionary: \n%@", delegate.emotionsFromPList);
    }
}

- (int)randomNumberFrom:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}

- (void)testCreateDemoRecords {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    MoodLogEvents *newMoodLogEntry;
    NSArray *emotionArray;
    MlMoodDataItem *aMood;
    emotionArray = [delegate.emotionsFromPList copy];
    NSArray *entries = @[
                         @[@"-10", @"Expected to hear back from the college by today. I'm impatient! Also bored. Also tired, I guess. I'm not exactly sure how I feel today. I think I need something to distract me.", @[@"Bored", @"Disappointed", @"Irritated"], @[@-3,@2,@-10,@1,@5,@-6]],
                         @[@"-9", @"Windy outside. I don't want to do my chores. Want to stay on the couch and read a book! Hole up here where it's safe and warm until the world comes to find me.", @[@"Cautious", @"Uneasy"], @[@-4,@-2,@-10,@-1,@4,@-5]],
                         @[@"-8", @"Sis's soccer team won! They played their rivals and this was the first time in three years that they won. 3-2. Sis scored one of the goals even! Luckily yesterday's wind died down and it was warm and sunny.", @[@"Proud"], @[@9,@5,@9,@6,@8,@2]],
                         @[@"-7", @"I've been accepted! I can't believe it. I'm going to college! There's so much to do. This is really huge. Can't write, gotta call Samantha.", @[@"Ecstatic", @"Happy", @"Triumphant"], @[@10,@6,@10,@-5,@7,@5]],
                         @[@"-6", @"There's this lady that walks her dog in our neighborhood. I swear she passes our apartments at the exact same time every day. I don't want my life to be like that, that predictable. I'm going to follow the path of least expectance.", @[@"Aggravated", @"Displeased", @"Suspicious"], @[@-3,@-5,@8,@5,@3,@5]],
                         @[@"-5", @"The bus driver was really funny today. I was sitting in front and he told stories about his time as a grill cook and the things that they would do as practical jokes to each other at the restaurant. Bus was mostly empty, so just me and one other passenger heard the stories.", @[@"Amused"], @[@8,@10,@4,@5,@9,@8]],
                         @[@"-5", @"Best friend is sad. They haven't heard anything. They're afraid that maybe they didn't get in and that's why they've heard nothing. I feel bad for Sam. I hope they're wrong.", @[@"Caring", @"Embarrassed", @"Regretful", @"sad", @"Sympathetic"], @[@-8,@-4,@-6,@4,@5,@4]],
                         @[@"-4", @"My best friend is angry with me. Says it's not fair. Says I'll lose touch with them. It wasn't exactly a fight, but we aren't speaking at the moment. Also the bus was late, but I made it to work just in time.", @[@"Angry", @"Annoyed", @"Irritated", @"Resenting"], @[@-10,@-10,@7,@-10,@5,@-5]],
                         @[@"-3", @"I'm feeling down today, thinking about leaving home and living in a strange place and not seeing my sister. She's sick today too, and I'm afraid I'm going to come down sick. Also, it's raining. Bleah. And the college is kinda weird - no grades, funky schedule. I don't know if I'll fit in.", @[@"Fearful", @"Insecure", @"Uneasy", @"Worried"], @[@-10,@-6,@-10,@-4,@-7,@-4]],
                         @[@"-2", @"Today is my official last day at my job. I'm glad it's over, but I also will miss my coworkers. Some of it was pretty fun.", @[@"Melancholy", @"Pleased"], @[@4,@4,@5,@6,@3,@5]],
                         @[@"-2", @"My boss wrote me a recommendation! I'll be able to take this with me and use it to help get a job sometime in the future.", @[@"Glad", @"Proud"], @[@8,@6,@4,@-3,@6,@8]],
                         @[@"-1", @"Mom was really empathetic today. She and I had a long talk about college and I told her my fears and then we went out for ice cream and to look at college supplies. It helped. She calls the college 'non-traditional' which is mom-speak for 'funky.' But she thinks they'll be really good for me, a good fit. Hope so.", @[@"Empathetic", @"Relieved", @"Sentimental"], @[@7,@3,@3,@10,@7,@7]],
                         @[@"-0", @"Everything just changed — they called to tell me they got in! They're accepted! We'll be going to college together! Apparently I’m totally forgiven too, so we’re best friends again. Tomorrow they're coming over. We have a lot of planning to do.", @[@"Elated", @"Relieved"], @[@10,@4,@10,@8,@7,@5]]
                         ];
    for (NSArray *entry in entries) {
        newMoodLogEntry = [[delegate masterViewController] insertNewObjectAndReturnReference:self];
        NSDate *theDate = [NSDate date];
        int backdate = ((NSString *)entry[0]).intValue;
        theDate = [theDate dateByAddingTimeInterval:(86400*backdate)];
        theDate = [theDate dateByAddingTimeInterval:[self randomNumberFrom:-(24*60*60)/6 to:(24*60*60)/24]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components;

        NSString *journal = (NSString *)entry[1];
        newMoodLogEntry.dateCreated = theDate;
        newMoodLogEntry.date = theDate;
        components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:newMoodLogEntry.date];
        newMoodLogEntry.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
        newMoodLogEntry.journalEntry = journal;

        NSArray *moods = (NSArray *)entry[2];
        NSArray *factors = (NSArray *)entry[3];
        NSString *test = @"";
        for (NSString *mood in moods) {
            test = [test stringByAppendingFormat:@"%@ ", mood];
        }
        newMoodLogEntry.overall = (NSNumber *)(factors[0]);
        newMoodLogEntry.stress = (NSNumber *)(factors[1]);
        newMoodLogEntry.energy = (NSNumber *)(factors[2]);
        newMoodLogEntry.thoughts = (NSNumber *)(factors[3]);
        newMoodLogEntry.health = (NSNumber *)(factors[4]);
        newMoodLogEntry.sleep = (NSNumber *)(factors[5]);
        for (NSString *mood in moods) {
            for (MlMoodDataItem *emotion in emotionArray) {
                if ([emotion.mood.lowercaseString isEqualToString:mood.lowercaseString]) {
                    aMood = emotion;
                    [aMood setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
                    // Add emotion to the record
                    Emotions *emotion = [NSEntityDescription insertNewObjectForEntityForName:@"Emotions" inManagedObjectContext:[delegate managedObjectContext]];
                    emotion.name = aMood.mood;
                    emotion.category = aMood.category;
                    emotion.parrotLevel = [NSNumber numberWithInt:(int)[aMood.parrotLevel integerValue]];
                    emotion.feelValue = [NSNumber numberWithInt:(int)[aMood.feelValue integerValue]];
                    emotion.facePath = aMood.facePath;
                    emotion.selected = [NSNumber numberWithBool:YES];
                    emotion.logParent = newMoodLogEntry; // current record
                }
            }
        }
    }
    [delegate saveContext];
}

- (void)testCreatingAFewRecords {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    MoodLogEvents *newMoodLogEntry;
    NSArray *emotionArray;
    MlMoodDataItem *aMood;
    int randomEmotionIndex;
    int randomNumberOfEmotions;
    NSDate *theDate = [NSDate date]; // start with today
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components;
    
    int MAXRECORDS = 10;
    for (int i =0; i < MAXRECORDS; i++) {
        newMoodLogEntry = [[delegate masterViewController] insertNewObjectAndReturnReference:self];
        // Skip back in time after a few records
        if (i%(arc4random()%4 + 1) == 0){
            theDate = [theDate dateByAddingTimeInterval:-86400];
            NSLog(@"Going back in time...");
        }
        // Change the time for every entry -1440 to 1440 (24*60)
        theDate = [theDate dateByAddingTimeInterval:[self randomNumberFrom:-1440 to:1440]];
        
        newMoodLogEntry.dateCreated = theDate;
        newMoodLogEntry.date = theDate;
        components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:newMoodLogEntry.date];
        newMoodLogEntry.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
        
        // NSLog(@"New Mood: %@",newMoodLogEntry);
        [newMoodLogEntry setJournalEntry:[NSString stringWithFormat:@"TEST %d, test data generated automatically", i]];
        [newMoodLogEntry setOverall:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setStress:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setEnergy:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setThoughts:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setHealth:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setSleep:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        emotionArray = [delegate.emotionsFromPList copy];
        randomNumberOfEmotions = [self randomNumberFrom:0 to:8];
        for (int j=0; j < randomNumberOfEmotions; j++) {
            randomEmotionIndex = (arc4random()%([emotionArray count] - 1));
            aMood = [emotionArray objectAtIndex:randomEmotionIndex];
            [aMood setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
            // Add emotion to the record
            Emotions *emotion = [NSEntityDescription insertNewObjectForEntityForName:@"Emotions" inManagedObjectContext:[delegate managedObjectContext]];
            emotion.name = aMood.mood;
            emotion.category = aMood.category;
            emotion.parrotLevel = [NSNumber numberWithInt:(int)[aMood.parrotLevel integerValue]];
            emotion.feelValue = [NSNumber numberWithInt:(int)[aMood.feelValue integerValue]];
            emotion.facePath = aMood.facePath;
            emotion.selected = [NSNumber numberWithBool:YES];
            emotion.logParent = newMoodLogEntry; // current record
            
        }
        if (i%20 == 0) {
            NSLog(@"Saving (%d of %d)...",i,MAXRECORDS);
            [delegate saveContext];
            
        }
    }
    NSLog(@"Finishing testCreatingAFewRecords.");
    [delegate saveContext];
}

- (void)testCreatingLotsOfRecords {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    MoodLogEvents *newMoodLogEntry;
    NSArray *emotionArray;
    MlMoodDataItem *aMood;
    int randomEmotionIndex;
    int randomNumberOfEmotions;
    NSDate *theDate = [NSDate date]; // start with today
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components;
   
    int MAXRECORDS = 800;
    for (int i =0; i < MAXRECORDS; i++) {
        newMoodLogEntry = [[delegate masterViewController] insertNewObjectAndReturnReference:self];
        // Skip back in time after a few records
        if (i%(arc4random()%4 + 1) == 0){
            theDate = [theDate dateByAddingTimeInterval:-86400];
            NSLog(@"Going back in time...");
        }
        // Change the time for every entry -1440 to 1440 (24*60)
        theDate = [theDate dateByAddingTimeInterval:[self randomNumberFrom:-1440 to:1440]];

        newMoodLogEntry.dateCreated = theDate;
        newMoodLogEntry.date = theDate;
        components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:newMoodLogEntry.date];
        newMoodLogEntry.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
        
        // NSLog(@"New Mood: %@",newMoodLogEntry);
        [newMoodLogEntry setJournalEntry:[NSString stringWithFormat:@"TEST %d, test data generated automatically", i]];
        [newMoodLogEntry setOverall:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setStress:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setEnergy:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setThoughts:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setHealth:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        [newMoodLogEntry setSleep:[NSNumber numberWithInt:(arc4random()%20 - 10)]];
        emotionArray = [delegate.emotionsFromPList copy];
        randomNumberOfEmotions = [self randomNumberFrom:0 to:20];
        for (int j=0; j < randomNumberOfEmotions; j++) {
            randomEmotionIndex = (arc4random()%([emotionArray count] - 1));
            aMood = [emotionArray objectAtIndex:randomEmotionIndex];
            [aMood setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
            // Add emotion to the record
            Emotions *emotion = [NSEntityDescription insertNewObjectForEntityForName:@"Emotions" inManagedObjectContext:[delegate managedObjectContext]];
            emotion.name = aMood.mood;
            emotion.category = aMood.category;
            emotion.parrotLevel = [NSNumber numberWithInt:(int)[aMood.parrotLevel integerValue]];
            emotion.feelValue = [NSNumber numberWithInt:(int)[aMood.feelValue integerValue]];
            emotion.facePath = aMood.facePath;
            emotion.selected = [NSNumber numberWithBool:YES];
            emotion.logParent = newMoodLogEntry; // current record

        }
        if (i%20 == 0) {
            NSLog(@"Saving (%d of %d)...",i,MAXRECORDS);
            [delegate saveContext];

        }
    }
    NSLog(@"Finishing testCreatingLotsOfRecords.");
    [delegate saveContext];
}

- (void)XtestExportingToPList {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSUInteger events = [sectionInfo numberOfObjects];
    MoodLogEvents *moodLogRecord;
    NSIndexPath *itemIndexPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *filePath = [basePath stringByAppendingPathComponent:@"exportedData.plist"];
    
    NSMutableArray *plistArray = [[NSMutableArray alloc] init];
   if (events > 0) {
        for(int i=0; i<events;i++) {
            itemIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            moodLogRecord = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
            NSMutableDictionary *entryDictionary = [[NSMutableDictionary alloc] init];
            NSString *journalEntry = moodLogRecord.journalEntry;
            if (journalEntry == Nil) {
                journalEntry = @"";
            }
            [entryDictionary setObject:journalEntry forKey:@"journalEntry"];
            [entryDictionary setObject:moodLogRecord.date forKey:@"date"];
            [entryDictionary setObject:moodLogRecord.dateCreated forKey:@"dateCreated"];
            moodLogRecord.overall  ? [entryDictionary setObject:moodLogRecord.overall forKey:@"mood"] :[entryDictionary setObject:[NSNumber numberWithInt:0] forKey:@"mood"];
            moodLogRecord.stress   ? [entryDictionary setObject:moodLogRecord.stress forKey:@"stress"] :[entryDictionary setObject:[NSNumber numberWithInt:0] forKey:@"stress"];
            moodLogRecord.energy   ? [entryDictionary setObject:moodLogRecord.energy forKey:@"energy"] :[entryDictionary setObject:[NSNumber numberWithInt:0] forKey:@"energy"];
            moodLogRecord.thoughts ? [entryDictionary setObject:moodLogRecord.thoughts forKey:@"mindfulness"] :[entryDictionary setObject:[NSNumber numberWithInt:0] forKey:@"mindfulness"];
            moodLogRecord.health   ? [entryDictionary setObject:moodLogRecord.health forKey:@"health"] :[entryDictionary setObject:[NSNumber numberWithInt:0] forKey:@"health"];
            moodLogRecord.sleep    ? [entryDictionary setObject:moodLogRecord.sleep forKey:@"sleep"] :[entryDictionary setObject:[NSNumber numberWithInt:0] forKey:@"sleep"];
            
            // Get the emotion list
            NSSet *emotionsFromRecord = moodLogRecord.relationshipEmotions; // Get all the emotions for this record
            NSPredicate *selectedPredicate = [NSPredicate predicateWithFormat:@"selected == YES"];
            NSSet *selectedEmotionsFromRecord = [emotionsFromRecord filteredSetUsingPredicate:selectedPredicate];
            NSMutableArray *emotionArray = [[NSMutableArray alloc] init];
            for (Emotions *emotion in selectedEmotionsFromRecord) {
                [emotionArray addObject:emotion.name];
            }
           [entryDictionary setObject:emotionArray forKey:@"emotionArray"];

            NSLog(@"Writing entry: %@",entryDictionary);
            [plistArray addObject:entryDictionary];
        }
    }
   BOOL written = [plistArray writeToFile:filePath atomically:YES];
    if (written) {
        NSLog(@"Saved data to: \"%@\"",filePath);
    }
    else {
        XCTFail(@"Something went wrong writing to \"%@\"",filePath);
    }
    NSLog(@"Finishing testExportingToPList.");
}

- (void)XtestImportingFromPList {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    MoodLogEvents *newMoodLogEntry;
    NSDictionary *emotionsMasterDictionary;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *filePath = [basePath stringByAppendingPathComponent:@"exportedData.plist"];
    NSMutableArray* importArray = [[NSMutableArray alloc]
                                      initWithContentsOfFile:filePath];
    if ([importArray count] > 0) {
        for(NSDictionary *moodLogItemDictionary in importArray) {
            newMoodLogEntry = [[delegate masterViewController] insertNewObjectAndReturnReference:self];
            newMoodLogEntry.dateCreated = [moodLogItemDictionary objectForKey:@"dateCreated"];
            newMoodLogEntry.date = [moodLogItemDictionary objectForKey:@"date"];
            components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:newMoodLogEntry.date];
            newMoodLogEntry.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
            
            newMoodLogEntry.journalEntry = [moodLogItemDictionary objectForKey:@"journalEntry"];
            [newMoodLogEntry setOverall:[moodLogItemDictionary objectForKey:@"mood"]];
            [newMoodLogEntry setStress:[moodLogItemDictionary objectForKey:@"stress"]];
            [newMoodLogEntry setEnergy:[moodLogItemDictionary objectForKey:@"energy"]];
            [newMoodLogEntry setThoughts:[moodLogItemDictionary objectForKey:@"mindfulness"]];
            [newMoodLogEntry setHealth:[moodLogItemDictionary objectForKey:@"health"]];
            [newMoodLogEntry setSleep:[moodLogItemDictionary objectForKey:@"sleep"]];
            emotionsMasterDictionary = [delegate.moodListDictionary copy];
            NSArray *emotionsToImportArray = [moodLogItemDictionary objectForKey:@"emotionArray"];
            for (NSString *emotionName in emotionsToImportArray) {
                id aMood = [emotionsMasterDictionary objectForKey:emotionName];
                // Add emotion to the record
                Emotions *emotion = [NSEntityDescription insertNewObjectForEntityForName:@"Emotions" inManagedObjectContext:[delegate managedObjectContext]];
                emotion.name = emotionName;
                emotion.category = [aMood objectForKey:@"category"];
                emotion.parrotLevel = [NSNumber numberWithInt:(int)[[aMood objectForKey:@"parrotLevel"] integerValue]];
                emotion.feelValue = [NSNumber numberWithInt:(int)[[aMood objectForKey:@"feelValue"] integerValue]];
                emotion.facePath = [aMood objectForKey:@"facePath"];
                emotion.selected = [NSNumber numberWithBool:YES];
                emotion.logParent = newMoodLogEntry; // current record
                
            }
        }
    }
    [delegate saveContext];
    NSLog(@"Finishing testImportingFromPList.");
}

- (void)XtestDeletingAllRecords {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSUInteger events = [sectionInfo numberOfObjects];
    MoodLogEvents *moodLogRecord;
    NSIndexPath *itemIndexPath;
    if (events > 0) {
        for(int i=0; i<events;i++) {
            itemIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            moodLogRecord = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
            [[delegate managedObjectContext] deleteObject:moodLogRecord];
            if ((i%20) == 0) {
                [delegate saveContext];
            }
        }
        [delegate saveContext];
    }
    
    NSLog(@"Finishing testDeletingAllRecords.");
    [delegate saveContext];
}


#pragma mark - Core Data delegate methods

- (NSFetchedResultsController *)fetchedResultsController {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MoodLogEvents" inManagedObjectContext:[delegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[delegate managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"An unknown error has occurred:  %@, %@", error, [error userInfo]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving Mood Log data", @"Core data saving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data unknown error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
	    abort();
	}
    
    return _fetchedResultsController;
}


@end
