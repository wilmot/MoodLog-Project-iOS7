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
        newMoodLogEntry.dateCreated = theDate;
        newMoodLogEntry.date = theDate;
        components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:newMoodLogEntry.date];
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
        randomNumberOfEmotions = (arc4random()%8);
        for (int j=0; j < randomNumberOfEmotions; j++) {
            randomEmotionIndex = (arc4random()%([emotionArray count] - 1));
            aMood = [emotionArray objectAtIndex:randomEmotionIndex];
            [aMood setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
            // Add emotion to the record
            Emotions *emotion = [NSEntityDescription insertNewObjectForEntityForName:@"Emotions" inManagedObjectContext:[delegate managedObjectContext]];
            emotion.name = aMood.mood;
            emotion.category = aMood.category;
            emotion.parrotLevel = [NSNumber numberWithInt:[aMood.parrotLevel integerValue]];
            emotion.feelValue = [NSNumber numberWithInt:[aMood.feelValue integerValue]];
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
        newMoodLogEntry.dateCreated = theDate;
        newMoodLogEntry.date = theDate;
        components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:newMoodLogEntry.date];
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
        randomNumberOfEmotions = (arc4random()%100);
        for (int j=0; j < randomNumberOfEmotions; j++) {
            randomEmotionIndex = (arc4random()%([emotionArray count] - 1));
            aMood = [emotionArray objectAtIndex:randomEmotionIndex];
            [aMood setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
            // Add emotion to the record
            Emotions *emotion = [NSEntityDescription insertNewObjectForEntityForName:@"Emotions" inManagedObjectContext:[delegate managedObjectContext]];
            emotion.name = aMood.mood;
            emotion.category = aMood.category;
            emotion.parrotLevel = [NSNumber numberWithInt:[aMood.parrotLevel integerValue]];
            emotion.feelValue = [NSNumber numberWithInt:[aMood.feelValue integerValue]];
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

- (void)testExportingToPList {
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
            components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:newMoodLogEntry.date];
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
                emotion.parrotLevel = [NSNumber numberWithInt:[[aMood objectForKey:@"parrotLevel"] integerValue]];
                emotion.feelValue = [NSNumber numberWithInt:[[aMood objectForKey:@"feelValue"] integerValue]];
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
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to student@voyageropen.org", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
	    abort();
	}
    
    return _fetchedResultsController;
}


@end
