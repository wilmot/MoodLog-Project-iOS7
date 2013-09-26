//
//  MlSummaryInfoViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 9/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlSummaryInfoViewController.h"
#import "MlAppDelegate.h"

@interface MlSummaryInfoViewController ()

@end

@implementation MlSummaryInfoViewController

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
    [self summaryInformation];
}

- (void)summaryInformation {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    int events = [sectionInfo numberOfObjects];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDate *today = [object valueForKey:@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/YY"; // TODO: Make this world savvy
    NSString *startDate = [dateFormatter stringFromDate: today];
    
    indexPath = [NSIndexPath indexPathForItem:events - 1 inSection:0];
    object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    today = [object valueForKey:@"date"];
    dateFormatter.dateFormat = @"MM/dd/YY"; // TODO: Make this world savvy
    NSString *endDate = [dateFormatter stringFromDate: today];

    self.summaryText.text = [NSString stringWithFormat:@"Number of MoodLog Entries: %d from %@ to %@",events,startDate, endDate];
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
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
