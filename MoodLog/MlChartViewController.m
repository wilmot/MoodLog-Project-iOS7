//
//  MlChartViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlChartViewController.h"
#import "MlAppDelegate.h"

@interface MlChartViewController ()

@end

@implementation MlChartViewController

static short SUMMARY_CHART = 0;
static short PIE_CHART = 1;
static short BAR_CHART = 2;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.myChartCollectionViewController.chartType = @"Bar"; // Default chart type
//    [self.segment setTintColor:[UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.0]];
//    [self.toolBar setTintColor:[UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.managedObjectContext = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSUInteger events = [sectionInfo numberOfObjects];
    if (events > 0) {
        self.noRecordsView.hidden = YES;
    }
    else {
        self.noRecordsView.hidden = NO;
    }
    self.segment.selectedSegmentIndex = [defaults integerForKey:@"ChartSegmentState"];
    [self chooseSegment:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChartCollectionSegue"]) {
        self.myChartCollectionViewController = [segue destinationViewController]; // Getting a reference to the collection view
    }
    else if ([segue.identifier isEqualToString:@"SummarySegue"]) {
        self.mySummaryInfoViewController = [segue destinationViewController]; // Getting a reference to the Summary view
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSegment:nil];
    [self setToolBar:nil];
    [[self myChartCollectionViewController] setManagedObjectContext:nil];
    [self setMyChartCollectionViewController:nil];
    [super viewDidUnload];
}
- (IBAction)pressDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chooseSegment:(id)sender {
    if(self.segment.selectedSegmentIndex == SUMMARY_CHART) { // Summary
        self.summaryView.hidden = NO;
        self.mySummaryInfoViewController.showSummary = YES;
        [self.mySummaryInfoViewController summaryInformationQuick:self];
        [self.mySummaryInfoViewController performSelector:@selector(summaryInformationSlow:) withObject:self afterDelay:0.2 ];
        self.chartContainer.hidden = YES;
    }
    else if (self.segment.selectedSegmentIndex == BAR_CHART) { // Bar Chart
        self.summaryView.hidden = YES;
        self.mySummaryInfoViewController.showSummary = NO;
        self.chartContainer.hidden = NO;
        self.myChartCollectionViewController.chartType = @"Bar";
    }
    else if (self.segment.selectedSegmentIndex == PIE_CHART) {
        self.summaryView.hidden = YES;
        self.mySummaryInfoViewController.showSummary = NO;
        self.chartContainer.hidden = NO;
        self.myChartCollectionViewController.chartType = @"Pie";
    }
    else {
        // there is no fourth option
    }
    [self.myChartCollectionViewController setCellType:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.segment.selectedSegmentIndex forKey:@"ChartSegmentState"];
    [defaults synchronize];
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; //mainCacheName
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to student@voyageropen.org", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
	}
    
    return _fetchedResultsController;
}

@end
