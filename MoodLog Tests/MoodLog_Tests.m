//
//  MoodLog_Tests.m
//  MoodLog Tests
//
//  Created by Barry Langdon-Lassagne on 9/20/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MlAppDelegate.h"
#import "Emotions.h"

@interface MoodLog_Tests : XCTestCase

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

- (void)testMoodListDictionary {
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

- (void)testCreatingLotsOfRecords {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    MlAppDelegate *delegate =(MlAppDelegate *)sharedApplication.delegate;
    MoodLogEvents *newMoodLogEntry;
    NSArray *emotionArray;
    Emotions *aMood;
    int randomEmotionIndex;
    int randomNumberOfEmotions;
    
    for (int i =0; i < 100; i++) {
        newMoodLogEntry = [[delegate masterViewController] insertNewObjectAndReturnReference:self];
        // NSLog(@"New Mood: %@",newMoodLogEntry);
        [newMoodLogEntry setJournalEntry:[NSString stringWithFormat:@"TEST %d, test data generated automatically", i]];
        [newMoodLogEntry setOverall:[NSNumber numberWithInt:10]];
        [newMoodLogEntry setSleep:[NSNumber numberWithInt:8]];
        [newMoodLogEntry setEnergy:[NSNumber numberWithInt:6]];
        [newMoodLogEntry setHealth:[NSNumber numberWithInt:4]];
        emotionArray = [NSArray arrayWithObjects:[[[newMoodLogEntry relationshipEmotions] allObjects] sortedArrayUsingSelector:@selector(compare:)], nil];

        randomNumberOfEmotions = (arc4random()%100);
        for (int j=0; j < randomNumberOfEmotions; j++) {
            randomEmotionIndex = (arc4random()%([[emotionArray objectAtIndex:0] count] - 1));
            aMood = [[emotionArray objectAtIndex:0] objectAtIndex:randomEmotionIndex];
            [aMood setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
        }
    }
    [delegate saveContext];
}

@end
