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
}

- (void)summaryInformationQuick: (id)sender {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    int events = [sectionInfo numberOfObjects];
    
    NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:firstItemIndexPath];
    NSDate *today = [object valueForKey:@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MMMM dd, YYYY hh:mm a";
    NSString *startDate = [dateFormatter stringFromDate: today];
    
    NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForItem:events - 1 inSection:0];
    object = [self.fetchedResultsController objectAtIndexPath:lastItemIndexPath];
    today = [object valueForKey:@"date"];
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
- (void)summaryInformationSlow: (id)sender {
    if (self.showSummary) {
        UIFont *font;
        NSAttributedString *summaryLine;
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor blueColor], NSForegroundColorAttributeName, nil];
        NSMutableAttributedString *summaryAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.summaryText.attributedText];
        
        // Categories
        font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
        attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor darkTextColor], NSForegroundColorAttributeName, nil];
        summaryLine = [[NSAttributedString alloc] initWithString:@"\n\nCategories" attributes:attrsDictionary];
        [summaryAttributedString appendAttributedString:summaryLine];
        
        NSMutableDictionary *emotionCategoryAccumulation = [[NSMutableDictionary alloc] init];
        NSDictionary *emotionColors = @{love : [[UIColor greenColor] darkerColor], joy : [UIColor orangeColor], surprise : [UIColor purpleColor], anger : [UIColor redColor], sadness : [UIColor blueColor], fear : [[[UIColor yellowColor] darkerColor] darkerColor]};
        
        int numberOfSections = [[self.fetchedResultsController2 sections] count];
        for (int i=0; i<numberOfSections; i++) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController2 sections][i];
            [emotionCategoryAccumulation setObject:[NSNumber numberWithLong:[sectionInfo numberOfObjects]] forKey:sectionInfo.name];
        }
        
        for (NSString *category in @[@"Love", @"Joy",@"Surprise",@"Anger",@"Sadness", @"Fear"]) {
            NSNumber *countForCategory =[emotionCategoryAccumulation objectForKey:category];
            font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
            attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [emotionColors objectForKey:category], NSForegroundColorAttributeName, nil];
            summaryLine = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\t%@: %d ", category, [countForCategory integerValue]] attributes:attrsDictionary];
            [summaryAttributedString appendAttributedString:summaryLine];
            
        }
        
        self.summaryText.attributedText = summaryAttributedString;
        self.showSummary = NO;
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"MoodLogsCache"];
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"category" cacheName:@"EmotionsCache"];
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
