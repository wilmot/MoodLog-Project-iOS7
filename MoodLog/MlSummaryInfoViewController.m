//
//  MlSummaryInfoViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 9/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlSummaryInfoViewController.h"
#import "MlAppDelegate.h"
#import "Prefs.h"
#import "MlColorChoices.h"
#import "MlMoodDataItem.h"

@interface MlSummaryInfoViewController ()

@end

@implementation MlSummaryInfoViewController

BOOL hasShownSlowSummary = NO;
NSUInteger MAX_EMOTIONS_TO_DISPLAY = 25;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.managedObjectContext = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}

- (void) viewWillAppear:(BOOL)animated {
    [self summaryInformationQuick: self];
}

#pragma mark - Orientation change
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.barChartForSummary setNeedsDisplay];
}

//- (void)deviceOrientationDidChange:(NSNotification *)notification {
//    [self.class reloadData];
//}


- (void)summaryInformationQuick: (id)sender {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByDate sections][0];
    NSUInteger events = [sectionInfo numberOfObjects];
    if (events > 0) {
        NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        MoodLogEvents *moodLogRecord = [self.fetchedResultsControllerByDate objectAtIndexPath:firstItemIndexPath];
        NSDate *today = [moodLogRecord valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MMMM dd, YYYY hh:mm a";
        NSString *startDate = [dateFormatter stringFromDate: today];
        
        NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:events - 1 inSection:0];
        moodLogRecord = [self.fetchedResultsControllerByDate objectAtIndexPath:lastItemIndexPath];
        today = [moodLogRecord valueForKey:@"date"];
        dateFormatter.dateFormat = @"MMMM dd, YYYY hh:mm a";
        NSString *endDate = [dateFormatter stringFromDate: today];
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        NSAttributedString *summaryLine;
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blueColor], NSForegroundColorAttributeName, nil];
        NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:@"Summary Information" attributes:attrsDictionary];
        NSMutableAttributedString *summaryAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:titleString];
        
        
        // Summary of records and dates
        font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor darkTextColor], NSForegroundColorAttributeName, nil];
        NSString *textToDisplay;
        if (events > 1) {
            textToDisplay = [NSString stringWithFormat:@"\n\nYou have created %d Mood Log entries, dating from %@ to %@.", events, startDate, endDate];
        } else {
            textToDisplay = [NSString stringWithFormat:@"\n\nYou have created %d Mood Log entry, dating from %@ to %@.", events, startDate, endDate];
        }
        summaryLine = [[NSAttributedString alloc] initWithString:textToDisplay attributes:attrsDictionary];
        [summaryAttributedString appendAttributedString:summaryLine];
                
        self.summaryText.attributedText = summaryAttributedString;
    }
}
- (void)summaryInformationSlow: (id)sender {
    if (self.showSummary) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByDate sections][0];
        NSUInteger events = [sectionInfo numberOfObjects];
        if (events > 0) {
            UIFont *font;
            NSAttributedString *summaryLine;
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blueColor], NSForegroundColorAttributeName, nil];
            NSMutableAttributedString *summaryAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.summaryText.attributedText];
            
            // Categories
            font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
            attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor darkTextColor], NSForegroundColorAttributeName, nil];
            summaryLine = [[NSAttributedString alloc] initWithString:@"\n\nCategories" attributes:attrsDictionary];
            [summaryAttributedString appendAttributedString:summaryLine];
            
            NSMutableDictionary *categoryCounts = [@{love : @0, joy : @0, surprise : @0, anger : @0, sadness : @0, fear : @0} mutableCopy];
            
            NSUInteger numberOfSections = [[self.fetchedResultsControllerByCategory sections] count];
            for (int i=0; i<numberOfSections; i++) {
                id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByCategory sections][i];
                NSUInteger objectsInSection = [sectionInfo numberOfObjects];
                [categoryCounts setObject:[NSNumber numberWithLong:objectsInSection] forKey:sectionInfo.name];
            }
            
            for (NSString *category in @[@"Love", @"Joy",@"Surprise",@"Anger",@"Sadness", @"Fear"]) {
                NSNumber *countForCategory =[categoryCounts objectForKey:category];
                if ([countForCategory integerValue] > 0) {
                    font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
                    attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [[MlColorChoices textColors] objectForKey:category], NSForegroundColorAttributeName, nil];
                }
                else {
                    font = [UIFont fontWithName:@"HelveticaNeue" size:14];
                    attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [[MlColorChoices textDesaturatedColors] objectForKey:category], NSForegroundColorAttributeName, nil];
                }
                summaryLine = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\t%@: %d ", category, [countForCategory integerValue]] attributes:attrsDictionary];
                [summaryAttributedString appendAttributedString:summaryLine];
            }
            
            self.summaryText.attributedText = summaryAttributedString;
            
            
            self.pieChartForSummary.chartType = @"Pie";
            self.pieChartForSummary.categoryCounts = categoryCounts;
            self.pieChartForSummary.dividerLine = NO;
            [self.pieChartForSummary setNeedsDisplay];
            
            [self summaryInformationSlow2:self];
            [self summaryInformationSlowEmotions:self];
            self.showSummary = NO;
       }
    }
}

- (void)summaryInformationSlow2: (id)sender {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByDate sections][0];
    NSUInteger events = [sectionInfo numberOfObjects];
    if (events > 0) {
        UIFont *font;
        NSAttributedString *summaryLine;
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blueColor], NSForegroundColorAttributeName, nil];
        NSMutableAttributedString *summaryAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.summaryText.attributedText];
        
        // Categories
        font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
        attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor darkTextColor], NSForegroundColorAttributeName, nil];
        summaryLine = [[NSAttributedString alloc] initWithString:@"\n\nBars:" attributes:attrsDictionary];
        [summaryAttributedString appendAttributedString:summaryLine];

        NSIndexPath *itemIndexPath;
        MoodLogEvents *moodLogRecord;
        NSMutableDictionary *barTotals = [@{@"overall" : @0, @"sleep" : @0, @"energy" : @0, @"health" : @0} mutableCopy];
       for (int i =0; i<events; i++) {
            itemIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            moodLogRecord = [self.fetchedResultsControllerByDate objectAtIndexPath:itemIndexPath];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"overall"] floatValue] + [moodLogRecord.overall floatValue]] forKey:@"overall"];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"sleep"] floatValue] + [moodLogRecord.sleep floatValue]] forKey:@"sleep"];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"energy"] floatValue] + [moodLogRecord.energy floatValue]] forKey:@"energy"];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"health"] floatValue] + [moodLogRecord.health floatValue]] forKey:@"health"];
       }
        self.barChartForSummary.chartType = @"Bar";
        self.barChartForSummary.chartHeightOverall = [[barTotals objectForKey:@"overall"] floatValue]/events;
        self.barChartForSummary.chartHeightSleep = [[barTotals objectForKey:@"sleep"] floatValue]/events;
        self.barChartForSummary.chartHeightEnergy = [[barTotals objectForKey:@"energy"] floatValue]/events;
        self.barChartForSummary.chartHeightHealth = [[barTotals objectForKey:@"health"] floatValue]/events;
        [self.barChartForSummary setNeedsDisplay]; // without this, the bars don't match the data

        self.summaryText.attributedText = summaryAttributedString;
    }
}

- (void)summaryInformationSlowEmotions: (id)sender {
    if (self.showSummary) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByDate sections][0];
        NSUInteger events = [sectionInfo numberOfObjects];
        if (events > 0) {
            UIFont *font;
            NSAttributedString *summaryLine;
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blueColor], NSForegroundColorAttributeName, nil];
            NSMutableAttributedString *summaryAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.summaryText.attributedText];
            
            // Categories
            font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
            attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor darkTextColor], NSForegroundColorAttributeName, nil];
            summaryLine = [[NSAttributedString alloc] initWithString:@"\n\n\n\n\n\n\n\n\n\n\nMost Common Emotions" attributes:attrsDictionary];
            [summaryAttributedString appendAttributedString:summaryLine];
            
            // Set up font for body text
            font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];

            Emotions *emotionRecord;
            NSIndexPath *itemIndexPath;
            NSUInteger numberOfSections = [[self.fetchedResultsControllerByEmotion sections] count];
            NSMutableArray *summaryMoodArray = [[NSMutableArray alloc] init];
            for (int i=0; i<MIN(numberOfSections, MAX_EMOTIONS_TO_DISPLAY); i++) {
                id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByEmotion sections][i];
                NSUInteger objectsInSection = [sectionInfo numberOfObjects];
                itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:i];
                emotionRecord = [self.fetchedResultsControllerByEmotion objectAtIndexPath:itemIndexPath]; 
                MlMoodDataItem *thisMood = [[MlMoodDataItem alloc] init];
                thisMood.mood = emotionRecord.name;
                thisMood.category = emotionRecord.category;
                thisMood.itemCount =[NSNumber numberWithInt:objectsInSection];
                [summaryMoodArray addObject:thisMood];
            }
            for (MlMoodDataItem *anElement in [summaryMoodArray sortedArrayUsingSelector:@selector(itemCountReverseCompare:)]) {
                attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [[MlColorChoices textColors] objectForKey:anElement.category], NSForegroundColorAttributeName, nil];
                summaryLine = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\t%@: %@ ", anElement.mood, anElement.itemCount] attributes:attrsDictionary];
                [summaryAttributedString appendAttributedString:summaryLine];
           }
            self.summaryText.attributedText = summaryAttributedString;
            
            self.showSummary = NO;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Data delegate methods

- (NSFetchedResultsController *)fetchedResultsControllerByDate {
    if (_fetchedResultsControllerByDate != nil) {
        return _fetchedResultsControllerByDate;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MoodLogEvents" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *afetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; // @"MoodLogsCache"
    afetchedResultsController.delegate = self;
    self.fetchedResultsControllerByDate = afetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerByDate performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsControllerByDate;
}

- (NSFetchedResultsController *)fetchedResultsControllerByCategory {
    if (_fetchedResultsControllerByCategory != nil) {
        return _fetchedResultsControllerByCategory;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Emotions" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]]];
    [fetchRequest setPredicate:requestPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"category" cacheName:nil]; // @"EmotionsCache"
    aFetchedResultsController.delegate = self;
    self.fetchedResultsControllerByCategory = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerByCategory performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsControllerByCategory;
}

- (NSFetchedResultsController *)fetchedResultsControllerByEmotion {
    if (_fetchedResultsControllerByEmotion != nil) {
        return _fetchedResultsControllerByEmotion;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Emotions" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]]];
    [fetchRequest setPredicate:requestPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"name" cacheName:nil]; // @"EmotionsCache"
    aFetchedResultsController.delegate = self;
    self.fetchedResultsControllerByEmotion = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerByEmotion performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsControllerByEmotion;
}

@end
