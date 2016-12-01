//
//  MlSummaryInfoViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 9/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
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

- (void)summaryInformationQuick: (id)sender {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByDate sections][0];
    NSUInteger events = [sectionInfo numberOfObjects];
    if (events > 0) {
        NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        MoodLogEvents *moodLogRecord = [self.fetchedResultsControllerByDate objectAtIndexPath:firstItemIndexPath];
        NSDate *today = [moodLogRecord valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd, YYYY hh:mm a", @"MMMM dd, YYYY hh:mm a format");
        NSString *startDate = [dateFormatter stringFromDate: today];
        
        NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:events - 1 inSection:0];
        moodLogRecord = [self.fetchedResultsControllerByDate objectAtIndexPath:lastItemIndexPath];
        today = [moodLogRecord valueForKey:@"date"];
        dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd, YYYY hh:mm a", @"MMMM dd, YYYY hh:mm a format");
        NSString *endDate = [dateFormatter stringFromDate: today];
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        NSAttributedString *summaryLine;
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blueColor], NSForegroundColorAttributeName, nil];
        NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Summary Information", @"Title for Summary page") attributes:attrsDictionary];
        NSMutableAttributedString *summaryAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:titleString];
        
        
        // Summary of records and dates
        font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor darkTextColor], NSForegroundColorAttributeName, nil];
        NSString *textToDisplay;
        if (events > 1) {
            textToDisplay = [NSString stringWithFormat:NSLocalizedString(@"\n\nYou have created %d Mood Log entries, dating from %@ to %@.", @"\n\nYou have created %d Mood Log entries, dating from %@ to %@."), events, startDate, endDate];
        } else {
            textToDisplay = [NSString stringWithFormat:NSLocalizedString(@"\n\nYou have created %d Mood Log entry, dating from %@ to %@.", @"\n\nYou have created %d Mood Log entry, dating from %@ to %@. -- singular"), events, startDate, endDate];
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
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { // if iOS 7 or later
                summaryLine = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"\n\nCategories:", @"Categories - iOS 7") attributes:attrsDictionary];
            } else { // iOS 6
                summaryLine = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"\nCategories:", @"Categories - iOS 6") attributes:attrsDictionary];
            }
            [summaryAttributedString appendAttributedString:summaryLine];
            
            NSMutableDictionary *categoryCounts = [@{love : @0, joy : @0, surprise : @0, anger : @0, sadness : @0, fear : @0} mutableCopy];
            
            NSUInteger numberOfSections = [[self.fetchedResultsControllerByCategory sections] count];
            for (int i=0; i<numberOfSections; i++) {
                id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByCategory sections][i];
                NSUInteger objectsInSection = [sectionInfo numberOfObjects];
                [categoryCounts setObject:[NSNumber numberWithLong:objectsInSection] forKey:sectionInfo.name];
            }
            
            for (NSString *category in @[love, joy, surprise, anger, sadness, fear]) {
                NSNumber *countForCategory =[categoryCounts objectForKey:category];
                if ([countForCategory integerValue] > 0) {
                    font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
                    attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [[MlColorChoices textColors] objectForKey:category], NSForegroundColorAttributeName, nil];
                }
                else {
                    font = [UIFont fontWithName:@"HelveticaNeue" size:14];
                    attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [[MlColorChoices textDesaturatedColors] objectForKey:category], NSForegroundColorAttributeName, nil];
                }
                summaryLine = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"\n\t%@: %d ", @"category and count for category"), category, [countForCategory integerValue]] attributes:attrsDictionary];
                [summaryAttributedString appendAttributedString:summaryLine];
            }
            
            self.summaryText.attributedText = summaryAttributedString;
            
            
            self.pieChartForSummary.chartType = @"Pie";
            self.pieChartForSummary.categoryCounts = categoryCounts;
            self.pieChartForSummary.dividerLine = NO;
            self.pieChartForSummary.circumference = 60.0;
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
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { // if iOS 7 or later
            summaryLine = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"\n\nFactors:", @"Factors: - iOS 7") attributes:attrsDictionary];
        }
        else {
            summaryLine = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"\nFactors:", @"Factors: - iOS 6") attributes:attrsDictionary];
        }
        [summaryAttributedString appendAttributedString:summaryLine];

        NSIndexPath *itemIndexPath;
        MoodLogEvents *moodLogRecord;
        NSMutableDictionary *barTotals = [@{@"overall" : @0, @"stress" : @0, @"energy" : @0, @"thoughts" : @0, @"health" : @0, @"sleep" : @0} mutableCopy];
       for (int i =0; i<events; i++) {
            itemIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            moodLogRecord = [self.fetchedResultsControllerByDate objectAtIndexPath:itemIndexPath];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"overall"] floatValue] + [moodLogRecord.overall floatValue]] forKey:@"overall"];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"stress"] floatValue] + [moodLogRecord.stress floatValue]] forKey:@"stress"];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"energy"] floatValue] + [moodLogRecord.energy floatValue]] forKey:@"energy"];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"thoughts"] floatValue] + [moodLogRecord.thoughts floatValue]] forKey:@"thoughts"];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"health"] floatValue] + [moodLogRecord.health floatValue]] forKey:@"health"];
           [barTotals setObject:[NSNumber numberWithFloat:[[barTotals objectForKey:@"sleep"] floatValue] + [moodLogRecord.sleep floatValue]] forKey:@"sleep"];
       }
        self.barChartForSummary.chartType = @"Bar";
        self.barChartForSummary.chartHeightOverall = [[barTotals objectForKey:@"overall"] floatValue]/events;
        self.barChartForSummary.chartHeightStress = [[barTotals objectForKey:@"stress"] floatValue]/events;
        self.barChartForSummary.chartHeightEnergy = [[barTotals objectForKey:@"energy"] floatValue]/events;
        self.barChartForSummary.chartHeightThoughts = [[barTotals objectForKey:@"thoughts"] floatValue]/events;
        self.barChartForSummary.chartHeightHealth = [[barTotals objectForKey:@"health"] floatValue]/events;
        self.barChartForSummary.chartHeightSleep = [[barTotals objectForKey:@"sleep"] floatValue]/events;
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
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { // if iOS 7 or later
                summaryLine = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"\n\n\n\n\n\n\n\n\n\n\nMost Common Emotions:", @"Most Common Emotions: - iOS 7") attributes:attrsDictionary];
            }
            else {
                summaryLine = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"\n\n\n\n\n\n\n\n\nMost Common Emotions:", @"Most Common Emotions: - iOS 6") attributes:attrsDictionary];
            }
            [summaryAttributedString appendAttributedString:summaryLine];
            
            // Set up font for body text
            font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];

            Emotions *emotionRecord;
            NSIndexPath *itemIndexPath;
            NSUInteger numberOfSections = [[self.fetchedResultsControllerByEmotion sections] count];
            NSMutableArray *summaryMoodArray = [[NSMutableArray alloc] init];
            for (int i=0; i < numberOfSections; i++) {
                id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerByEmotion sections][i];
                NSUInteger objectsInSection = [sectionInfo numberOfObjects];
                itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:i];
                emotionRecord = [self.fetchedResultsControllerByEmotion objectAtIndexPath:itemIndexPath]; 
                MlMoodDataItem *thisMood = [[MlMoodDataItem alloc] init];
                thisMood.mood = emotionRecord.name;
                thisMood.category = emotionRecord.category;
                thisMood.itemCount =[NSNumber numberWithInt:(int)objectsInSection];
                [summaryMoodArray addObject:thisMood];
            }
            int emotionCount = 0;
            for (MlMoodDataItem *anElement in [summaryMoodArray sortedArrayUsingSelector:@selector(itemCountReverseCompare:)]) {
                attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [[MlColorChoices textColors] objectForKey:anElement.category], NSForegroundColorAttributeName, nil];
                summaryLine = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"\n\t%@: %@ ", @"Mood and itemcount"), anElement.mood, anElement.itemCount] attributes:attrsDictionary];
                [summaryAttributedString appendAttributedString:summaryLine];
                emotionCount++;
                if (emotionCount >= MAX_EMOTIONS_TO_DISPLAY) {
                    break;
                }
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
	}
    
    return _fetchedResultsControllerByEmotion;
}

@end
