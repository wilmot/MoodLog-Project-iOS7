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
#import "Emotions.h"
#import <QuartzCore/QuartzCore.h>
#import "Prefs.h"

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
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
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
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    float events = [sectionInfo numberOfObjects];
    [self.startSlider setMinimumValue:0];
    [self.startSlider setMaximumValue:events - 1];
    [self.endSlider setMinimumValue:0];
    [self.endSlider setMaximumValue:events - 1];
        
    if (events > 0) {
        for (id item in self.itemsToDisableTogether) {
            ((UIControl *)item).enabled = YES;
        }
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
        
    }
    else {
        for (id item in self.itemsToDisableTogether) {
            ((UIControl *)item).enabled = NO;

        }
    }
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
    NSIndexPath *indexPath;
    MoodLogEvents *object;
    NSDate *today = [NSDate date];
    today = [today dateByAddingTimeInterval: -60*60*24*30]; // Subtract a month from today
    int monthOldEntry=0;
    NSDate *aDay;
    for (int i=[self.endSlider maximumValue]; i>0; i--) {
        indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aDay = [object valueForKey:@"date"];
        if ([aDay timeIntervalSince1970] <= [today timeIntervalSince1970]) {
            monthOldEntry = MIN(i+1,[self.endSlider maximumValue]);
            break;
        }
    }
    self.startSlider.value = monthOldEntry;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
}

- (IBAction)pressWeekButton:(id)sender {
    // Iterate backwards through the records until you get to the first one that's within a week old
    NSIndexPath *indexPath;
    MoodLogEvents *object;
    NSDate *today = [NSDate date];
    today = [today dateByAddingTimeInterval: -60*60*24*7]; // Subtract a week from today
    int weekOldEntry=0;
    NSDate *aDay;
    for (int i=[self.endSlider maximumValue]; i>0; i--) {
        indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aDay = [object valueForKey:@"date"];
        if ([aDay timeIntervalSince1970] < [today timeIntervalSince1970]) {
            NSLog(@"%d, %f",i+1,[self.endSlider maximumValue]);
            weekOldEntry = MIN(i+1,[self.endSlider maximumValue]);
            break;
        }
    }
    self.startSlider.value = weekOldEntry;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
}

- (IBAction)pressLatestButton:(id)sender {
    self.startSlider.value = [self.startSlider maximumValue];
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
}

- (IBAction)composeEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:[self.recipientList.text componentsSeparatedByString:@","]];
         //[NSArray arrayWithObject:self.recipientList.text]];
        [controller setSubject:[NSString stringWithFormat:@"Mood Logs for %@ (%@)",self.dateRangeLabel.text, self.eventCount.text]];
 
        NSMutableString *bodyText = [NSMutableString stringWithFormat:@"<b>%@</b><br>%@<br><br><font size=-2>",self.dateRangeLabel.text, self.eventCount.text];
        // loop through the records
        
        int startValue = (int)roundl(self.startSlider.value);
        int endValue = (int)roundl(self.endSlider.value);
        NSIndexPath *indexPath;
        MoodLogEvents *object;
        NSString *entry;
        NSDate *today;
        NSString *theDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"MMMM dd, YYYY hh:mm a";
        for (int i=startValue; i<=endValue; i++) {
            indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            object = [self.fetchedResultsController objectAtIndexPath:indexPath];
            today = [object valueForKey:@"date"];
            theDate = [dateFormatter stringFromDate: today];
            [bodyText appendFormat:@"<b>%@:</b><br>", theDate];
            entry = [object valueForKey:@"journalEntry"];
            if (entry) {
                [bodyText appendFormat:@"Journal Entry: %@<br>Emotions:<br>",entry];
            }
            NSSet *emotionsforEntry = object.relationshipEmotions; // Get all the emotions for this record
            NSPredicate *myFilter = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]];
            NSArray *emotionArray = [[[emotionsforEntry filteredSetUsingPredicate:myFilter] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSMutableString *selectedEms = [[NSMutableString alloc] init];
            for (id emotion in emotionArray) {
                //[selectedEms appendFormat:@"%@ ", [((Emotions *)emotion).name lowercaseString]];
                [selectedEms appendFormat:@"%@ ", ((Emotions *)emotion).name ];
            }
            [bodyText appendFormat:@"%@<br><br>",selectedEms];
       }

        [controller setMessageBody:bodyText isHTML:YES];
        if (controller) [self presentViewController:controller animated:YES completion:nil];
    }
}

- (IBAction)updatedRecipientList:(id)sender {
    [defaults setValue:self.recipientList.text forKey:@"DefaultRecipientList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (IBAction)testCreateNewRecord:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.masterViewController insertNewObject:self];
}

# pragma mark mail delegate methods
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        // NSLog(@"It's away!");
        [controller dismissViewControllerAnimated:YES completion:^(void) {
            [self dismissViewControllerAnimated:YES completion:nil]; // Also dismiss the Mail settings view controller
        }];
        
    }
    else {
        // NSLog(@"Mail composed, but not sent");
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
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

- (IBAction)finishedSlidingStartSlider:(id)sender {
    int discreteEndValue = roundl([self.startSlider value]);
    [self.startSlider setValue:(float)discreteEndValue];
    if (self.startSlider.value > self.endSlider.value) {
        [self.endSlider setValue:(float)discreteEndValue];
    }
    [self updateDateRangeDrawing];
}

- (IBAction)finishedSlidingEndSlider:(id)sender {
    int discreteEndValue = roundl([self.endSlider value]);
    [self.endSlider setValue:(float)discreteEndValue];
    if (self.endSlider.value < self.startSlider.value) {
        [self.startSlider setValue:(float)discreteEndValue];
    }
    [self updateDateRangeDrawing];
}

- (void) updateDateRangeDrawing {
    int startValue = (int)roundl(self.startSlider.value);
    int endValue = (int)roundl(self.endSlider.value);
    int events = (endValue - startValue) + 1;
    [self.recipientList resignFirstResponder];
    if (startValue > -1) {
        NSString *text;
        switch (events) {
            case 0:
                text = @"No entries";
                break;
            case 1:
                text = @"entry";
                break;
            default:
                text = @"entries";
                break;
        }
        self.eventCount.text = [NSString stringWithFormat:@"%d %@",events, text];
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
        
        if (self.startSlider.maximumValue > 0) {
            self.dateRangeDrawing.startValue = [NSNumber numberWithFloat:self.startSlider.value/self.startSlider.maximumValue];
            self.dateRangeDrawing.endValue = [NSNumber numberWithFloat:self.endSlider.value/self.endSlider.maximumValue];
        } else {
            self.dateRangeDrawing.startValue = [NSNumber numberWithFloat:self.startSlider.value/1.0];
            self.dateRangeDrawing.endValue = [NSNumber numberWithFloat:self.endSlider.value/1.0];
        }
        [self.dateRangeDrawing setNeedsDisplay];
        
        [defaults setFloat:self.startSlider.value forKey:@"DefaultMailStartValue"];
        [defaults setFloat:self.endSlider.value forKey:@"DefaultMailEndValue"];

    }
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
