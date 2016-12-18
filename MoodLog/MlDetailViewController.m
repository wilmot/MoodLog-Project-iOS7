//
//  MlDetailViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlDetailViewController.h"
#import "MlMasterViewController.h"
#import "MlAppDelegate.h"
#import "MlDatePickerViewController.h"
#import "MlJournalEditorViewController.h"
#import "MlSlidersViewController.h"
#import "Prefs.h"
#import "MlColorChoices.h"

@interface MlDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MlDetailViewController

static MlDatePickerViewController *myDatePickerViewController;

typedef NS_ENUM(NSInteger, DetailCells) {
    CALENDAR,
    EMOTIONS,
    JOURNAL,
    SLIDERS,
    ADDENTRYBUTTON
};

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            // iPad
            [self configureView];
        }
    }
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
    // Set the background for any states you plan to use
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { // prior to iOS 7 -- iOS 6 and lower
        [self.slidersSetAdjustButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.slidersSetAdjustButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self saveContext];
}

#pragma mark - Orientation change
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.sliderChartView setNeedsDisplay];
    [self.moodsDrawingView setNeedsDisplay];
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        for (id object in self.tableViewCellCollection) {
            ((UITableViewCell *)object).hidden = NO;
        }
        self.addEntryTableViewCell.hidden = YES;

        NSDate *today = [self.detailItem valueForKey:@"date"];
        
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *weekdayComponents =
        [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
        NSInteger day = [weekdayComponents day];
        NSInteger weekday = [weekdayComponents weekday];
 
        static NSArray *dayNames = nil;
        if (!dayNames) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setCalendar:[NSCalendar currentCalendar]];
            dayNames = [formatter weekdaySymbols];
        }
        
        self.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        self.weekdayLabel.text = [NSString stringWithFormat:@"%@", dayNames[weekday-1]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");
        
        self.timeLabel.text = [dateFormatter stringFromDate: today];
        
        dateFormatter.dateFormat = NSLocalizedString(@"MMMM YYYY", @"Month Year data format");
        self.monthLabel.text = [dateFormatter stringFromDate: today];
        
        if (self.detailItem.journalEntry.length > 0) {
            // There's interesting content
            self.entryLogTextView.textColor = [UIColor blackColor];
            [self.entryLogTextView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
            self.entryLogTextView.textAlignment = NSTextAlignmentLeft;
            self.entryLogTextView.text = self.detailItem.journalEntry;
            self.littleKeyboardIcon.hidden = YES;
            self.noJournalLabel.hidden = YES;
        }
        else {
            self.entryLogTextView.text = @""; // Empty journal entry
            self.littleKeyboardIcon.hidden = NO;
            self.noJournalLabel.hidden = NO;
        }
        
        // Set the Pie Chart and list of moods
        // Fetch the Mood list for this journal entry
        NSSet *emotionsforEntry = self.detailItem.relationshipEmotions; // Get all the emotions for this record
        NSPredicate *myFilter = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]];
        NSArray *emotionArray = [[[emotionsforEntry filteredSetUsingPredicate:myFilter] allObjects] sortedArrayUsingSelector:@selector(compare:)];
        NSString *selectedEms = [[NSString alloc] init];
        NSUInteger emotionArrayCount = [emotionArray count];
        CGFloat feelTotal = 0;
        
        NSMutableDictionary *categoryCounts = [@{love : @0, joy : @0, surprise : @0, anger : @0, sadness : @0, fear : @0} mutableCopy];
        NSMutableAttributedString *selectedEmotions = [[NSMutableAttributedString alloc] init];
        if (emotionArrayCount > 0) {
            NSString *thisCategory;
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
            NSDictionary *attrsDictionary;
            NSAttributedString *currentEmotion;
           for (Emotions *emotion in emotionArray) {
               attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [[MlColorChoices textColors] objectForKey:emotion.category], NSForegroundColorAttributeName, nil];
                currentEmotion = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",[emotion.name lowercaseString]] attributes:attrsDictionary];
                selectedEms = [selectedEms stringByAppendingFormat:@"%@: %@\n", emotion.category, [emotion.name lowercaseString]];
                [selectedEmotions appendAttributedString:currentEmotion];
                feelTotal += emotion.feelValue.floatValue;
                thisCategory = emotion.category;
                if (categoryCounts[thisCategory]) {
                    categoryCounts[thisCategory] = @([categoryCounts[thisCategory] integerValue] + [@1 integerValue]); // increment
                }
            }
            [selectedEmotions appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attrsDictionary]];
        }
        self.moodsDrawingView.chartType = @"Pie";
        self.moodsDrawingView.circumference = 46.0;
        self.moodsDrawingView.categoryCounts = categoryCounts;
        self.moodsDrawingView.dividerLine = NO;
        [self.moodsDrawingView setNeedsDisplay];
        self.moodListTextView.attributedText = selectedEmotions;
        
        // Set the sliders
        [self.overallSlider setValue:[[self.detailItem valueForKey:@"overall"] floatValue]];
        [self.stressSlider setValue:[[self.detailItem valueForKey:@"stress"] floatValue]];
        [self.energySlider setValue:[[self.detailItem valueForKey:@"energy"] floatValue]];
        [self.thoughtsSlider setValue:[[self.detailItem valueForKey:@"thoughts"] floatValue]];
        [self.healthSlider setValue:[[self.detailItem valueForKey:@"health"] floatValue]];
        [self.sleepSlider setValue:[[self.detailItem valueForKey:@"sleep"] floatValue]];
        // Set the slider colors
        [self setSliderColor:self.overallSlider];
        [self setSliderColor:self.stressSlider];
        [self setSliderColor:self.energySlider];
        [self setSliderColor:self.thoughtsSlider];
        [self setSliderColor:self.healthSlider ];
        [self setSliderColor:self.sleepSlider];
 
        [self setVisibilityOfNoMoodsLabel]; // Should only show if there are no moods selected
        [self setVisibilityOfNoFactorsLabel]; // Only show if all the factors are zeroed
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            // iPad
            if (self.detailItem.editing.boolValue == YES) {
                [self.expandButton setTitle:NSLocalizedString(@"Done", @"Done button") forState:UIControlStateNormal];
            } else {
                [self.expandButton setTitle:NSLocalizedString(@"Edit", @"Edit button") forState:UIControlStateNormal];
            }
        }
        [self.entryLogTextView setDelegate:self];
        [self.blankCoveringView setHidden:YES];
        [self.scrollView setHidden:NO];
        [self.detailToolBar setRightBarButtonItem:nil animated:YES];        
    }
    else { // Nothing selected
        [self.blankCoveringView setHidden:NO];
        [self.scrollView setHidden:YES];
        [self.detailToolBar setRightBarButtonItem:nil animated:YES];
        
        for (id object in self.tableViewCellCollection) {
            ((UITableViewCell *)object).hidden = YES;
        }
        self.addEntryTableViewCell.hidden = NO;
       
        if ((self.detailItem.editing.boolValue == NO) && (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)) {
            [self.moodContainer setHidden:NO];
        }

    }
    [self setSliderCellVisibility];
    [self.tableView reloadData];
}

- (void) setSliderCellVisibility {
    if (self.detailItem.sliderValuesSet.boolValue || (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)) { // If the chart is visible
        self.sliderChartView.chartType = @"Bar";
        [self.sliderChartView setChartHeightOverall:[self.detailItem.overall floatValue]];
        [self.sliderChartView setChartHeightStress:[self.detailItem.stress floatValue]];
        [self.sliderChartView setChartHeightEnergy:[self.detailItem.energy floatValue]];
        [self.sliderChartView setChartHeightThoughts:[self.detailItem.thoughts floatValue]];
        [self.sliderChartView setChartHeightHealth:[self.detailItem.health floatValue]];
        [self.sliderChartView setChartHeightSleep:[self.detailItem.sleep floatValue]];
        self.sliderChartView.dividerLine = NO;
        [self.sliderChartView setNeedsDisplay];

        self.slidersView.hidden = YES;
        [self.slidersSetAdjustButton setTitle:NSLocalizedString(@"Adjust", @"Adjust button") forState:UIControlStateNormal];

    }
    else {
        self.slidersView.hidden = NO;
        [self.slidersSetAdjustButton setTitle:NSLocalizedString(@"Lock", @"Lock button") forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master button");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (IBAction)pressedSlidersSetAdjustButton:(id)sender {
    // Toggle the Set/Adjust value
    self.detailItem.sliderValuesSet=[NSNumber numberWithBool:!self.detailItem.sliderValuesSet.boolValue];
    [self setSliderCellVisibility];
    [self saveContext];
    [self.tableView reloadData];
}

- (IBAction)pressedDoneButton:(id)sender {
    // is it a Done button or an Edit button?
    [self.entryLogTextView resignFirstResponder];
    [self.detailToolBar setRightBarButtonItem:nil animated:YES];
}

- (void) moveSlider:(id) sender {
    float sliderValue = [[NSNumber numberWithFloat:[(UISlider *)sender value]] floatValue];
    static float previousValue;
    
    if (fabsf(sliderValue - previousValue) >= 1) {
        [self setSliderColor:sender];
        previousValue = sliderValue;
    }
}

- (void) setSliderColor:(id) sender {
    float sliderValue = [[NSNumber numberWithFloat:[(UISlider *)sender value]] floatValue];
    UIColor *sliderColor;
    if (sliderValue >= 0) { // Tint green
        sliderColor = [UIColor colorWithRed:fabs((sliderValue  - 10.0)/20.0) green:(sliderValue + 10.0)/20.0 blue:1.0 - (sliderValue + 10.0)/20.0 alpha:sliderAlpha];
    }
    else { // Tint red
        sliderColor = [UIColor colorWithRed:fabs((sliderValue - 10.0)/20.0) green:(sliderValue + 10.0)/20.0 blue:1.0 - fabs((sliderValue - 10.0)/20.0) alpha:sliderAlpha];
    }
//    [(UISlider *)sender setMaximumTrackTintColor:sliderColor];
//    [(UISlider *)sender setMinimumTrackTintColor:sliderColor];
    [(UISlider *)sender setBackgroundColor:sliderColor];
}

- (void) setSliderData:(id) sender {
    NSString *key;
    if ([self.overallSlider isEqual:sender]) {
        key = @"overall";
    }
    else if ([self.stressSlider isEqual:sender]) {
        key = @"stress";
    }
    else if ([self.energySlider isEqual:sender]) {
        key = @"energy";
    }
    else if ([self.thoughtsSlider isEqual:sender]) {
        key = @"thoughts";
    }
    else if ([self.healthSlider isEqual:sender]) {
        key = @"health";
    }
    else if ([self.sleepSlider isEqual:sender]) {
        key = @"sleep";
    }
    
    NSNumber *sliderValue = [NSNumber numberWithFloat:[(UISlider *)sender value]];
    [self.detailItem setValue:sliderValue forKey:key];
}

- (void) saveContext { // Save data to the database
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Error saving Mood Log data", @"Core data saving error alert title")
                                     message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]]
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MoodFullScreenSegue"]) {
        [self pressedDoneButton:self]; // Make sure textfield isn't still in edit mode
        ((MlMoodCollectionViewController *)[segue destinationViewController]).detailItem = self.detailItem;
    }
    else if ([segue.identifier isEqualToString:@"DatePicker"]) {
        // do stuff around the date & time
        myDatePickerViewController = [segue destinationViewController];
        myDatePickerViewController.detailItem = self.detailItem;
        myDatePickerViewController.dateToSet = self.detailItem.date;
        myDatePickerViewController.detailViewController = self;
    }
    else if ([segue.identifier isEqualToString:@"journalEditor"]) {
        // edit the journal entry text
        MlJournalEditorViewController *myJournalEntryViewController = [segue destinationViewController];
        myJournalEntryViewController.detailItem = self.detailItem;
        myDatePickerViewController.detailViewController = self;
    }
    else if ([segue.identifier isEqualToString:@"slidersSegue"]) {
        MlSlidersViewController *mySlidersViewController = [segue destinationViewController];
        mySlidersViewController.detailItem = self.detailItem;
    }
    else if ([segue.identifier isEqualToString:@"chartView"]) {
        // iPad Only
       // [[segue destinationViewController] setManagedObjectContext:self.detailItem.managedObjectContext];
    }
}

- (void) setSortStyle: (NSString *)style {
    self.detailItem.sortStyle = style;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        self.detailItem.sortStyleEditing = style;
    }
}

- (IBAction)addEntryFromStartScreen:(id)sender {
    MlMasterViewController *controller = [(MlAppDelegate *)[UIApplication sharedApplication].delegate masterViewController];
    [controller insertNewObject:self];
}

- (IBAction)pressedExpandButton:(id)sender { // Edit/Done button
    [self.noMoodsLabel setHidden:YES]; // Hide the label when starting an edit session
    [self.noMoodsImage setHidden:YES];
    [self pressedDoneButton:self];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        // iPad
        if ([self.expandButton.titleLabel.text isEqual:NSLocalizedString(@"Edit", @"Edit button")]) {
            [self.expandButton setTitle:NSLocalizedString(@"Done", @"Done button") forState:UIControlStateNormal];
            self.detailItem.editing = [NSNumber numberWithBool:YES];
            [self.myMoodCollectionViewController refresh];
        }
        else {
            [self.expandButton setTitle:NSLocalizedString(@"Edit", @"Edit button") forState:UIControlStateNormal];
            self.detailItem.editing = [NSNumber numberWithBool:NO];
            [self.myMoodCollectionViewController refresh];
        }
        [self setVisibilityOfNoMoodsLabel];
    }
    else { // iPhone
        // On the iPhone I have a segue to a modal view, so I don't change the button text
   }
    
    [self saveContext];
}

- (void) setVisibilityOfNoMoodsLabel {
    BOOL shouldHideLabel = YES;
    if (self.moodListTextView.text.length == 0) {
            shouldHideLabel = NO; // Should only show if there are no emotions selected
    }
    [self.noMoodsLabel setHidden:shouldHideLabel];
    [self.noMoodsImage setHidden:shouldHideLabel];
}

- (void) setVisibilityOfNoFactorsLabel {
    BOOL shouldHideLabel = YES;
    if ([[self.detailItem valueForKey:@"overall"] floatValue] == 0 && [[self.detailItem valueForKey:@"stress"] floatValue] == 0 && [[self.detailItem valueForKey:@"energy"] floatValue] == 0 && [[self.detailItem valueForKey:@"thoughts"] floatValue] == 0 && [[self.detailItem valueForKey:@"health"] floatValue] == 0 && [[self.detailItem valueForKey:@"sleep"] floatValue] == 0) {
        shouldHideLabel = NO; // Should only show if none of the factors are modified
    }
    [self.noFactorsLabel setHidden:shouldHideLabel];
    [self.noFactorsImage setHidden:shouldHideLabel];
    [self.sliderChartView setHidden:!shouldHideLabel];    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    CGSize textViewSize;
    UIInterfaceOrientation orientation;
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (indexPath.section) {
        case CALENDAR: //Calendar
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                height = 128.0;
            } else {
                height = 62.0;
            }
            break;
        case EMOTIONS:
            if (self.moodListTextView.text.length == 0) {
                height = 100.0;
            }
            else {
                if (orientation == UIInterfaceOrientationPortrait) {
                    textViewSize = [self.moodListTextView sizeThatFits:CGSizeMake(273.0, FLT_MAX)];
                }
                else {
                    textViewSize = [self.moodListTextView sizeThatFits:CGSizeMake(521.0, FLT_MAX)];
                }
                height = textViewSize.height - 16.0;
                if (height < 100.0) { height = 100.0;}
            }
            break;
        case JOURNAL: //Journal
            if (orientation == UIInterfaceOrientationPortrait) {
                textViewSize = [self.entryLogTextView sizeThatFits:CGSizeMake(273.0, FLT_MAX)];
            }
            else {
                textViewSize = [self.entryLogTextView sizeThatFits:CGSizeMake(521.0, FLT_MAX)];
            }
            height = textViewSize.height + 20.0;
            break;
       case SLIDERS: //Sliders & Slider Chart
            height = 104.0;
            break;
        case ADDENTRYBUTTON:
            if (self.detailItem == nil) {
                height = 100.0;
            }
            else {
                height = 0.0;
            }
            break;
        default:
            height = 100.0;
            break;
    }
    return height;
}

#pragma mark - Entry Log UITextView delegate methods
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.detailToolBar setRightBarButtonItem:self.doneButton animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.detailToolBar setRightBarButtonItem:nil animated:YES];
 
    [textView resignFirstResponder];
    // Save the database record.
    [self.detailItem setValue:[self.entryLogTextView text] forKey:@"journalEntry"];
    [self saveContext];
}

- (void)viewDidUnload {
    [self setMoodContainer:nil];
    [self setMonthLabel:nil];
    [self setSortABCButton:nil];
    [self setSortCBAButton:nil];
    [self setSortShuffleButton:nil];
    [self setToggleFacesButton:nil];
    [self setBlankCoveringView:nil];
    [self setExpandButton:nil];
    [self setMoodViewWithHeader:nil];
    [self setExpandButton:nil];
    [self setSortGroupButton:nil];
    [self setNoMoodsLabel:nil];
    [super viewDidUnload];
}
@end
