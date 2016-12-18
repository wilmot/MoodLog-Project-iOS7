//
//  MlMailViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
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
    NSUInteger events = [sectionInfo numberOfObjects];
    
    if (events > 0) {
        [self.startSlider setMinimumValue:0];
        [self.startSlider setMaximumValue:events - 1];
        [self.endSlider setMinimumValue:0];
        [self.endSlider setMaximumValue:events - 1];
        for (id item in self.itemsToDisableTogether) {
            ((UIControl *)item).enabled = YES;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSDate *today = [object valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = NSLocalizedString(@"MM/dd/YY", @"MM/dd/YY format");
        self.startDateLabel.text = [dateFormatter stringFromDate: today];
        
        indexPath = [NSIndexPath indexPathForItem:events - 1 inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        today = [object valueForKey:@"date"];
        dateFormatter.dateFormat = NSLocalizedString(@"MM/dd/YY", @"MM/dd/YY format");
        self.endDateLabel.text = [dateFormatter stringFromDate: today];

        // Position the sliders and highlight the buttons
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.startSlider.value = [defaults floatForKey:@"DefaultMailStartValue"];
        self.endSlider.value = [defaults floatForKey:@"DefaultMailEndValue"];
        self.recipientList.text = [defaults stringForKey:@"DefaultRecipientList"];
        
        if ([defaults boolForKey:@"MailSliderPinnedToNewest"] == YES) {
            self.endSlider.value = self.endSlider.maximumValue;
        }
        if ([defaults boolForKey:@"MailLatestButtonOn"]) {
            self.latestButton.selected = YES;
            [self pressLatestButton:self];
        }
        else if ([defaults boolForKey:@"Mail7DayButtonOn"]) {
            self.weekButton.selected = YES;
            [self pressWeekButton:self];
        }
        else if ([defaults boolForKey:@"Mail30DayButtonOn"]) {
            self.monthButton.selected = YES;
            [self pressMonthButton:self];
        }
        else if ([defaults boolForKey:@"MailAllButtonOn"]) {
            self.allButton.selected = YES;
            [self pressAllButton:self];
        }
        [self updateDateRangeDrawing];
    }
    else {
        [self.startSlider setMinimumValue:0];
        [self.startSlider setMaximumValue:0];
        [self.endSlider setMinimumValue:0];
        [self.endSlider setMaximumValue:0];
        for (id item in self.itemsToDisableTogether) {
            ((UIControl *)item).enabled = NO;

        }
    }
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
    [self saveSliderState];
    [self setButtonHighlighting:self.allButton];
}

- (IBAction)pressMonthButton:(id)sender {
    NSIndexPath *indexPath;
    MoodLogEvents *object;
    NSDate *today = [NSDate date];
    today = [today dateByAddingTimeInterval: -60*60*24*30]; // Subtract a month from today
    int monthOldEntry=0;
    NSDate *aDay;
    for (int i=[self.endSlider maximumValue]; i>=0; i--) {
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
    [self saveSliderState];
    [self setButtonHighlighting:self.monthButton];
}

- (IBAction)pressWeekButton:(id)sender {
    // Iterate backwards through the records until you get to the first one that's within a week old
    NSIndexPath *indexPath;
    MoodLogEvents *object;
    NSDate *today = [NSDate date];
    today = [today dateByAddingTimeInterval: -60*60*24*7]; // Subtract a week from today
    int weekOldEntry=0;
    NSDate *aDay = [[NSDate alloc] init];
    for (int i=[self.endSlider maximumValue]; i>=0; i--) {
        indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aDay = [object valueForKey:@"date"];
        if ([aDay timeIntervalSince1970] < [today timeIntervalSince1970]) {
            weekOldEntry = MIN(i+1,[self.endSlider maximumValue]);
            break;
        }
    }
    self.startSlider.value = weekOldEntry;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
    [self saveSliderState];
    [self setButtonHighlighting:self.weekButton];
}

- (IBAction)pressLatestButton:(id)sender {
    self.startSlider.value = [self.startSlider maximumValue];
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
    [self saveSliderState];
    [self setButtonHighlighting:self.latestButton];
}

- (void) setButtonHighlighting: (UIButton *)button {
    // Clear all the buttons
    [self.latestButton setSelected:NO];
    [self.weekButton setSelected:NO];
    [self.monthButton setSelected:NO];
    [self.allButton setSelected:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"MailLatestButtonOn"];
    [defaults setBool:NO forKey:@"Mail7DayButtonOn"];
    [defaults setBool:NO forKey:@"Mail30DayButtonOn"];
    [defaults setBool:NO forKey:@"MailAllButtonOn"];
    // Set the one you want
    if (button != Nil) {
        // Determine which button was pressed so I can set the state and the defaults
        if (button == self.latestButton) {
            [defaults setBool:YES forKey:@"MailLatestButtonOn"];
            [self.latestButton setSelected:YES];
        }
        else if (button == self.weekButton) {
            [defaults setBool:YES forKey:@"Mail7DayButtonOn"];
            [self.weekButton setSelected:YES];
        }
        else if (button == self.monthButton) {
            [defaults setBool:YES forKey:@"Mail30DayButtonOn"];
            [self.monthButton setSelected:YES];
        }
        else if (button == self.allButton) {
            [defaults setBool:YES forKey:@"MailAllButtonOn"];
            [self.allButton setSelected:YES];
        }
    }
    [defaults synchronize];
}

- (IBAction)composeEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:[self.recipientList.text componentsSeparatedByString:@","]];
        [controller setSubject:[NSString stringWithFormat:@"Mood Logs for %@ (%@)",self.dateRangeLabel.text, self.eventCount.text]];
 
        NSMutableString *bodyText = [NSMutableString stringWithFormat:@"<b>%@</b><br><i>%@</i><br><br><font size=-2>",self.dateRangeLabel.text, self.eventCount.text];
        // loop through the records
        
        int startValue = (int)roundl(self.startSlider.value);
        int endValue = (int)roundl(self.endSlider.value);
        NSIndexPath *indexPath;
        MoodLogEvents *object;
        NSString *entry;
        NSDate *today;
        NSString *theDate;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd, YYYY hh:mm a", @"MMMM dd, YYYY hh:mm a format");
        for (int i=startValue; i<=endValue; i++) {
            indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            object = [self.fetchedResultsController objectAtIndexPath:indexPath];
            today = [object valueForKey:@"date"];
            theDate = [dateFormatter stringFromDate: today];
            [bodyText appendFormat:@"<b>%@</b><br>", theDate];
            [bodyText appendFormat:@"<blockquote>"];
            entry = [object valueForKey:@"journalEntry"];
            if (entry) {
                [bodyText appendFormat:NSLocalizedString(@"<b>Journal Entry</b>:<br><blockquote>%@</blockquote>", @"Journal Entry preface in email"), entry];
            }
            [bodyText appendFormat:@"<b>Emotions</b>:<br><blockquote>"];
            NSSet *emotionsforEntry = object.relationshipEmotions; // Get all the emotions for this record
            NSPredicate *myFilter = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]];
            NSArray *emotionArray = [[[emotionsforEntry filteredSetUsingPredicate:myFilter] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSMutableString *selectedEms = [[NSMutableString alloc] init];
            for (id emotion in emotionArray) {
                [selectedEms appendFormat:@"%@ ", ((Emotions *)emotion).name ];
            }
            if ([emotionArray count] == 0) {
                [bodyText appendFormat:@"None chosen"];
            }
            [bodyText appendFormat:@"%@</blockquote>",selectedEms];
            
            // Get the additional factors
            [bodyText appendFormat:@"<b>Factors</b>:<br><blockquote>"];
           if ([object.overall integerValue] == 0 && [object.stress integerValue] == 0 && [object.energy integerValue] == 0 && [object.thoughts integerValue] ==0 && [object.health integerValue] == 0 && [object.sleep integerValue] == 0) {
               [bodyText appendFormat:@"None selected"];
            }
            else {
                [bodyText appendFormat:@"Mood: %ld<br>",(long)[object.overall integerValue]];
                [bodyText appendFormat:@"Stress: %ld<br>",(long)[object.stress integerValue]];
                [bodyText appendFormat:@"Energy: %ld<br>",(long)[object.energy integerValue]];
                [bodyText appendFormat:@"Thoughts: %ld<br>",(long)[object.thoughts integerValue]];
                [bodyText appendFormat:@"Health: %ld<br>",(long)[object.health integerValue]];
                [bodyText appendFormat:@"Sleep: %ld<br>",(long)[object.sleep integerValue]];
            }
            [bodyText appendFormat:@"</blockquote><br>"];
            [bodyText appendFormat:@"</blockquote>"];
     }

        [controller setMessageBody:bodyText isHTML:YES];
        if (controller) [self presentViewController:controller animated:YES completion:nil];
    }
}

- (IBAction)updatedRecipientList:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.recipientList.text forKey:@"DefaultRecipientList"];
    [defaults synchronize];
    
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
        [controller dismissViewControllerAnimated:YES completion:^(void) {
            [self dismissViewControllerAnimated:YES completion:nil]; // Also dismiss the Mail settings view controller
        }];
        
    }
    else {
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
    [self setButtonHighlighting:nil];
}

- (IBAction)slideEndSlider:(id)sender {
   if (self.endSlider.value < self.startSlider.value) {
       [self.startSlider setValue:[self.endSlider value]];
    }
    [self updateDateRangeDrawing];
    [self setButtonHighlighting:nil];
}

- (IBAction)finishedSlidingStartSlider:(id)sender {
    int discreteEndValue = roundl([self.startSlider value]);
    [self.startSlider setValue:(float)discreteEndValue];
    if (self.startSlider.value > self.endSlider.value) {
        [self.endSlider setValue:(float)discreteEndValue];
    }
    [self updateDateRangeDrawing];
    [self saveSliderState];
}

- (IBAction)finishedSlidingEndSlider:(id)sender {
    int discreteEndValue = roundl([self.endSlider value]);
    [self.endSlider setValue:(float)discreteEndValue];
    if (self.endSlider.value < self.startSlider.value) {
        [self.startSlider setValue:(float)discreteEndValue];
    }
    [self updateDateRangeDrawing];
    [self saveSliderState];
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
                text = NSLocalizedString(@"No entries", @"No entries - Mail range picker");
                break;
            case 1:
                text = NSLocalizedString(@"entry", @"entry - Mail range picker");
                break;
            default:
                text = NSLocalizedString(@"entries", @"entries - Mail range picker");
                break;
        }
        self.eventCount.text = [NSString stringWithFormat:@"%d %@",events, text];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:startValue inSection:0];
        MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSDate *today = [object valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd, YYYY", @"MMMM dd, YYYY date format");
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
        
    }
}

- (void) saveSliderState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.startSlider.value forKey:@"DefaultMailStartValue"];
    [defaults setFloat:self.endSlider.value forKey:@"DefaultMailEndValue"];
    if (self.endSlider.value == self.endSlider.maximumValue) {
        [defaults setBool:YES forKey:@"MailSliderPinnedToNewest"];
    }
    else {
        [defaults setBool:NO forKey:@"MailSliderPinnedToNewest"];
    }
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
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
                                     message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data unknown error alert text"), error, [error userInfo]]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK button")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                   }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
	}
    
    return _fetchedResultsController;
}


@end
