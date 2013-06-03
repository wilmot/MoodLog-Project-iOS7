//
//  MlMailViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlMailViewController.h"
#import "MlAppDelegate.h"
#import "MoodLogEvents.h"
#import <QuartzCore/QuartzCore.h> 

@interface MlMailViewController ()

@end

@implementation MlMailViewController

NSUserDefaults *defaults;

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
    self.managedObjectContext = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}

- (void) viewWillAppear:(BOOL)animated {
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
    // Set the background for any states you plan to use
    [self.allButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.allButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.monthButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.monthButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.weekButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.weekButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.latestButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.latestButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.composeButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.composeButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    float events = [sectionInfo numberOfObjects];
    [self.startSlider setMinimumValue:0];
    [self.startSlider setMaximumValue:events - 1];
    [self.endSlider setMinimumValue:0];
    [self.endSlider setMaximumValue:events - 1];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDate *today = [object valueForKey:@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/YY"; // TODO: Make this world savvy
    self.startDateLabel.text = [dateFormatter stringFromDate: today];

    indexPath = [NSIndexPath indexPathForItem:events - 1 inSection:0];
    object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    today = [object valueForKey:@"date"];
    dateFormatter.dateFormat = @"MM/dd/YY"; // TODO: Make this world savvy
    self.endDateLabel.text = [dateFormatter stringFromDate: today];
//    self.eventCountView.layer.cornerRadius = 8;
//    self.eventCountView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.eventCountView.layer.shadowOpacity = 0.4;
//    self.eventCountView.layer.shadowRadius = 12;
//    self.eventCountView.layer.shadowOffset = CGSizeMake(4.0f, 4.0f);
    
    defaults = [NSUserDefaults standardUserDefaults];
    self.startSlider.value = [defaults floatForKey:@"DefaultMailStartValue"];
    self.endSlider.value = [defaults floatForKey:@"DefaultMailEndValue"];
    self.recipientList.text = [defaults stringForKey:@"DefaultRecipientList"];

    [self updateDateRangeDrawing];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidUnload {
    [self setStartSlider:nil];
    [self setEndSlider:nil];
    [self setAllButton:nil];
    [self setMonthButton:nil];
    [self setWeekButton:nil];
    [self setLatestButton:nil];
    [self setDateRangeDrawing:nil];
    [self setDateRangeDrawing:nil];
    [self setComposeButton:nil];
    [self setEventCount:nil];
    [self setDateRangeLabel:nil];
    [self setStartDateLabel:nil];
    [self setEndDateLabel:nil];
    [self setEventCountView:nil];
    [self setRecipientList:nil];
    [super viewDidUnload];
}
- (IBAction)pressAllButton:(id)sender {
    self.startSlider.value = 0.0;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
}

- (IBAction)pressMonthButton:(id)sender {
    self.startSlider.value = [self.endSlider maximumValue] / 2.0 ; // test data
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
}

- (IBAction)pressWeekButton:(id)sender {
    self.startSlider.value = [self.startSlider maximumValue] * 0.9;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
}

- (IBAction)pressLatestButton:(id)sender {
    self.startSlider.value = [self.startSlider maximumValue];
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
}

- (IBAction)composeEmail:(id)sender {
}

- (IBAction)updatedRecipientList:(id)sender {
    [defaults setValue:self.recipientList.text forKey:@"DefaultRecipientList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextfield {
    [aTextfield resignFirstResponder];
    return YES;
}

- (IBAction)slideStartSlider:(id)sender {
    if (self.startSlider.value > self.endSlider.value) {
        [self.endSlider setValue:[self.startSlider value]];
    }
    [self updateDateRangeDrawing];
}

- (IBAction)slideEndSlider:(id)sender {
    if (self.endSlider.value < self.startSlider.value) {
        [self.startSlider setValue:[self.endSlider value]];
    }
    [self updateDateRangeDrawing];
}

- (void) updateDateRangeDrawing {
    int startValue = (int)roundl(self.startSlider.value);
    int endValue = (int)roundl(self.endSlider.value);
    int records = (endValue - startValue) + 1;
    NSString *text = @"event";
    [self.recipientList resignFirstResponder];

    if (records > 1) {
        text = @"events";
    }
    self.eventCount.text = [NSString stringWithFormat:@"%d %@",records, text];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:startValue inSection:0];
    MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDate *today = [object valueForKey:@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MMMM dd, YYYY";
    NSString *startDate = [dateFormatter stringFromDate: today];
    
    indexPath = [NSIndexPath indexPathForItem:endValue inSection:0];
    object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    today = [object valueForKey:@"date"];
    NSString *endDate = [dateFormatter stringFromDate:today];
    
    if ([startDate isEqualToString:endDate]) {
        self.dateRangeLabel.text = [NSString stringWithFormat:@"%@", startDate];        
    }
    else {
        self.dateRangeLabel.text = [NSString stringWithFormat:@"%@ to %@", startDate, endDate];
    }

    
    self.dateRangeDrawing.startValue = [NSNumber numberWithFloat:self.startSlider.value/self.startSlider.maximumValue];
    self.dateRangeDrawing.endValue = [NSNumber numberWithFloat:self.endSlider.value/self.endSlider.maximumValue];
    [self.dateRangeDrawing setNeedsDisplay];
    
    [defaults setFloat:self.startSlider.value forKey:@"DefaultMailStartValue"];
    [defaults setFloat:self.endSlider.value forKey:@"DefaultMailEndValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
