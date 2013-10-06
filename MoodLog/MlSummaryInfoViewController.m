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

@interface MlSummaryInfoViewController ()

@end

@implementation MlSummaryInfoViewController

BOOL hasShownSlowSummary = NO;

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
//    Pass UILayoutConstraintAxisHorizontal for the constraints affecting [self center].x and CGRectGetWidth([self bounds]), and UILayoutConstraintAxisVertical for the constraints affecting[self center].y and CGRectGetHeight([self bounds]).

    NSLog(@"Constraints affecting [self center].x and width: %@",[self.view constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal]);
    NSLog(@"Constraints affecting [self center].y and height: %@",[self.view constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical]);
    NSLog(@"Has ambiguous layout? %hhd",[self.view hasAmbiguousLayout]);
    
    // Release notes for iOS 6 say to do this
    [self.summaryText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.pieChartForSummary setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.viewInsideScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)summaryInformationQuick: (id)sender {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    int events = [sectionInfo numberOfObjects];
    if (events > 0) {
        NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        MoodLogEvents *moodLogRecord = [self.fetchedResultsController objectAtIndexPath:firstItemIndexPath];
        NSDate *today = [moodLogRecord valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MMMM dd, YYYY hh:mm a";
        NSString *startDate = [dateFormatter stringFromDate: today];
        
        NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:events - 1 inSection:0];
        moodLogRecord = [self.fetchedResultsController objectAtIndexPath:lastItemIndexPath];
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
        summaryLine = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\nYou have created %d MoodLog Entries, dating from %@ to %@.", events, startDate, endDate] attributes:attrsDictionary];
        [summaryAttributedString appendAttributedString:summaryLine];
        
        // Most common emotion (same format as above)
        summaryLine = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\nThe most common emotion you've picked is “%@”", @"Pickle"] attributes:attrsDictionary];
        [summaryAttributedString appendAttributedString:summaryLine];
        
        self.summaryText.attributedText = summaryAttributedString;
    }
}
- (void)summaryInformationSlow: (id)sender {
    if (self.showSummary) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        int events = [sectionInfo numberOfObjects];
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
            
            int numberOfSections = [[self.fetchedResultsController2 sections] count];
            for (int i=0; i<numberOfSections; i++) {
                id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController2 sections][i];
                [categoryCounts setObject:[NSNumber numberWithLong:[sectionInfo numberOfObjects]] forKey:sectionInfo.name];
            }
            
            for (NSString *category in @[@"Love", @"Joy",@"Surprise",@"Anger",@"Sadness", @"Fear"]) {
                NSNumber *countForCategory =[categoryCounts objectForKey:category];
                font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
                attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [[MlColorChoices basicColors] objectForKey:category], NSForegroundColorAttributeName, nil];
                summaryLine = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\t%@: %d ", category, [countForCategory integerValue]] attributes:attrsDictionary];
                [summaryAttributedString appendAttributedString:summaryLine];
            }
            
            self.summaryText.attributedText = summaryAttributedString;
            
            
            self.pieChartForSummary.chartType = @"Pie";
            self.pieChartForSummary.categoryCounts = categoryCounts;
            self.pieChartForSummary.dividerLine = NO;
            [self.pieChartForSummary setNeedsDisplay];
            
            self.showSummary = NO;
       }
    }
}

- (void)summaryInformationSlow2: (id)sender {
    NSLog(@"summaryInformationSlow2");
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    int events = [sectionInfo numberOfObjects];
    float overall = 0, sleep = 0, energy =0, health = 0;
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
        for (int i =0; i<events; i++) {
            itemIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            moodLogRecord = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
            overall += [moodLogRecord.overall floatValue];
            sleep += [moodLogRecord.sleep floatValue];
            energy += [moodLogRecord.energy floatValue];
            health += [moodLogRecord.health floatValue];
        }
        self.barChartForSummary.chartType = @"Bar";
        self.barChartForSummary.chartHeightOverall = overall/events;
        self.barChartForSummary.chartHeightSleep = sleep/events;
        self.barChartForSummary.chartHeightEnergy = energy/events;
        self.barChartForSummary.chartHeightHealth = health/events;
        [self.barChartForSummary setNeedsDisplay]; // without this, the bars don't match the data

        self.summaryText.attributedText = summaryAttributedString;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Data delegate methods

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; // @"MoodLogsCache"
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

- (NSFetchedResultsController *)fetchedResultsController2 {
    if (_fetchedResultsController2 != nil) {
        return _fetchedResultsController2;
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
    self.fetchedResultsController2 = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController2 performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController2;
}

@end
