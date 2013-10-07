//
//  MoodLog_Tests.m
//  MoodLog Tests
//
//  Created by Barry Langdon-Lassagne on 9/20/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
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
        [newMoodLogEntry setOverall:[NSNumber numberWithInt:10]];
        [newMoodLogEntry setSleep:[NSNumber numberWithInt:8]];
        [newMoodLogEntry setEnergy:[NSNumber numberWithInt:6]];
        [newMoodLogEntry setHealth:[NSNumber numberWithInt:4]];
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
    NSLog(@"Finishing testCreatingLotsOfRecords.");
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
        [newMoodLogEntry setOverall:[NSNumber numberWithInt:10]];
        [newMoodLogEntry setSleep:[NSNumber numberWithInt:8]];
        [newMoodLogEntry setEnergy:[NSNumber numberWithInt:6]];
        [newMoodLogEntry setHealth:[NSNumber numberWithInt:4]];
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
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


@end
