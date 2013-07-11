    //
//  MlDetailViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlDetailViewController.h"
#import "MlMasterViewController.h"
#import "MlAppDelegate.h"
#import "MlDatePickerViewController.h"
#import "MlJournalEditorViewController.h"
#import "Prefs.h"

@interface MlDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MlDetailViewController

static MlDatePickerViewController *myDatePickerViewController;
NSUserDefaults *defaults;

typedef NS_ENUM(NSInteger, DetailCells) {
    CALENDAR,
    JOURNAL,
    MOODS, 
    SLIDERS,
    SLIDERSCHART
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
//    [self configureView];
    defaults = [NSUserDefaults standardUserDefaults];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.navigationController setToolbarHidden:YES animated: YES];
    if ((self.detailItem.editing.boolValue == NO) && (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)) {
        [self.moodContainer setHidden:NO];
    }
    [self configureView];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSDate *today = [self.detailItem valueForKey:@"date"];
        
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *weekdayComponents =
        [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];
        NSInteger day = [weekdayComponents day];
        NSInteger weekday = [weekdayComponents weekday];
 
        static NSArray *dayNames = nil;
        if (!dayNames) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setCalendar:[NSCalendar currentCalendar]];
            dayNames = [formatter weekdaySymbols];
        }
        
        self.dateLabel.text = [NSString stringWithFormat:@"%d", day];
        self.weekdayLabel.text = [NSString stringWithFormat:@"%@", dayNames[weekday-1]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"h:mm a";
        
        self.timeLabel.text = [dateFormatter stringFromDate: today];
        
        dateFormatter.dateFormat = @"MMM YYYY";
        self.monthLabel.text = [dateFormatter stringFromDate: today];
        
        if (self.detailItem.journalEntry.length > 0) {
            // There's interesting content
            self.entryLogTextView.textColor = [UIColor blackColor];
            [self.entryLogTextView setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12]];
            self.entryLogTextView.textAlignment = NSTextAlignmentLeft;
            self.entryLogTextView.text = self.detailItem.journalEntry;
            self.littleKeyboardIcon.hidden = YES;
        }
        else {
            self.entryLogTextView.textColor = [UIColor grayColor];
            [self.entryLogTextView setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18]];
            self.entryLogTextView.textAlignment = NSTextAlignmentRight;
            self.entryLogTextView.text = @"Touch to add a journal entry";
            self.littleKeyboardIcon.hidden = NO;
        }
        
        // Set the list of moods
        // Fetch the Mood list for this journal entry
        NSSet *emotionsforEntry = self.detailItem.relationshipEmotions; // Get all the emotions for this record
        NSPredicate *myFilter = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]];
        NSArray *emotionArray = [[[emotionsforEntry filteredSetUsingPredicate:myFilter] allObjects] sortedArrayUsingSelector:@selector(compare:)];
        NSString *selectedEms = [[NSString alloc] init];
        NSUInteger emotionArrayCount = [emotionArray count];
        CGFloat feelTotal = 0;
        
        NSMutableDictionary *categoryCounts = [@{love : @0, joy : @0, surprise : @0, fear : @0, anger : @0, sadness : @0} mutableCopy];
        if (emotionArrayCount > 0) {
            for (id emotion in emotionArray) {
                // selectedEms = [selectedEms stringByAppendingFormat:@"%@ (%@)\n", [((Emotions *)emotion).name lowercaseString], ((Emotions *)emotion).feelValue];
                selectedEms = [selectedEms stringByAppendingFormat:@"%@\n", [((Emotions *)emotion).name lowercaseString]];
                feelTotal += ((Emotions *)emotion).feelValue.floatValue;
                NSString *thisCategory = ((Emotions *)emotion).category;
                if (categoryCounts[thisCategory]) {
                    categoryCounts[thisCategory] = @([categoryCounts[thisCategory] integerValue] + [@1 integerValue]); // increment
                }
            }
        }
        self.moodListTextView.text = selectedEms;
        
        // Set the sliders
        [self.overallSlider setValue:[[self.detailItem valueForKey:@"overall"] floatValue]];
        [self.sleepSlider setValue:[[self.detailItem valueForKey:@"sleep"] floatValue]];
        [self.energySlider setValue:[[self.detailItem valueForKey:@"energy"] floatValue]];
        [self.healthSlider setValue:[[self.detailItem valueForKey:@"health"] floatValue]];
        // Set the slider colors
        [self setSliderColor:self.overallSlider];
        [self setSliderColor:self.sleepSlider];
        [self setSliderColor:self.energySlider];
        [self setSliderColor:self.healthSlider ];
        [self setVisibilityofNoMoodsLabel]; // Should only show if there are no moods selected
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            // iPad
            if (self.detailItem.editing.boolValue == YES) {
                [self.expandButton setTitle:@"Done" forState:UIControlStateNormal];
            } else {
                [self.expandButton setTitle:@"Edit" forState:UIControlStateNormal];
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
    }
    [self setSliderCellVisibility];
}

- (void) setSliderCellVisibility {
    NSIndexPath *slidersMoodIndexPath = [NSIndexPath indexPathForRow:0 inSection:SLIDERS];
    NSIndexPath *slidersSleepIndexPath = [NSIndexPath indexPathForRow:1 inSection:SLIDERS];
    NSIndexPath *slidersEnergyIndexPath = [NSIndexPath indexPathForRow:2 inSection:SLIDERS];
    NSIndexPath *slidersHealthIndexPath = [NSIndexPath indexPathForRow:3 inSection:SLIDERS];
    NSIndexPath *slidersDoneIndexPath = [NSIndexPath indexPathForRow:4 inSection:SLIDERS];
    NSIndexPath *slidersChartIndexPath = [NSIndexPath indexPathForRow:0 inSection:SLIDERSCHART];
    NSIndexPath *slidersAdjustIndexPath = [NSIndexPath indexPathForRow:1 inSection:SLIDERSCHART];
    if (self.detailItem.sliderValuesSet.boolValue) {
        self.sliderChartView.chartType = @"Bar";
        [self.sliderChartView setChartHeightOverall:[self.detailItem.overall floatValue]];
        [self.sliderChartView setChartHeightSleep:[self.detailItem.sleep floatValue]];
        [self.sliderChartView setChartHeightEnergy:[self.detailItem.energy floatValue]];
        [self.sliderChartView setChartHeightHealth:[self.detailItem.health floatValue]];
        [self.sliderChartView setNeedsDisplay];

        [self.tableView cellForRowAtIndexPath:slidersMoodIndexPath].hidden = YES;
        [self.tableView cellForRowAtIndexPath:slidersSleepIndexPath].hidden = YES;
        [self.tableView cellForRowAtIndexPath:slidersEnergyIndexPath].hidden = YES;
        [self.tableView cellForRowAtIndexPath:slidersHealthIndexPath].hidden = YES;
        [self.tableView cellForRowAtIndexPath:slidersDoneIndexPath].hidden = YES;
        [self.tableView cellForRowAtIndexPath:slidersChartIndexPath].hidden = NO;
        [self.tableView cellForRowAtIndexPath:slidersAdjustIndexPath].hidden = NO;
    }
    else {
        [self.tableView cellForRowAtIndexPath:slidersMoodIndexPath].hidden = NO;
        [self.tableView cellForRowAtIndexPath:slidersSleepIndexPath].hidden = NO;
        [self.tableView cellForRowAtIndexPath:slidersEnergyIndexPath].hidden = NO;
        [self.tableView cellForRowAtIndexPath:slidersHealthIndexPath].hidden = NO;
        [self.tableView cellForRowAtIndexPath:slidersDoneIndexPath].hidden = NO;
        [self.tableView cellForRowAtIndexPath:slidersChartIndexPath].hidden = YES;
        [self.tableView cellForRowAtIndexPath:slidersAdjustIndexPath].hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (IBAction)pressedDoneButton:(id)sender {
    // is it a Done button or an Edit button?
    [self.entryLogTextView resignFirstResponder];
    [self.detailToolBar setRightBarButtonItem:nil animated:YES];
}

- (IBAction)pressedSliderSetButton:(id)sender {
    // hide sliders
    // show pie
    self.detailItem.sliderValuesSet=[NSNumber numberWithBool:YES];
    [self saveContext];
    [self setSliderCellVisibility];
    [self.tableView reloadData];
}

- (IBAction)pressedSliderAdjustButton:(id)sender {
    // show sliders
    // hide pie
    self.detailItem.sliderValuesSet=[NSNumber numberWithBool:NO];
    [self saveContext];
    [self setSliderCellVisibility];
    [self.tableView reloadData];
}

- (void) moveSlider:(id) sender {
    float sliderValue = [[NSNumber numberWithFloat:[(UISlider *)sender value]] floatValue];
    static float previousValue;
    
    if (abs(sliderValue - previousValue) >= 1) {
        [self setSliderColor:sender];
        previousValue = sliderValue;
    }
}

- (void) setSliderColor:(id) sender {
    float sliderValue = [[NSNumber numberWithFloat:[(UISlider *)sender value]] floatValue];
    UIColor *sliderColor;
    if (sliderValue >= 0) { // Tint green
        sliderColor = [UIColor colorWithRed:fabsf((sliderValue  - 10.0)/20.0) green:(sliderValue + 10.0)/20.0 blue:1.0 - (sliderValue + 10.0)/20.0 alpha:1.0];
    }
    else { // Tint red
        sliderColor = [UIColor colorWithRed:fabsf((sliderValue - 10.0)/20.0) green:(sliderValue + 10.0)/20.0 blue:1.0 - fabsf((sliderValue - 10.0)/20.0) alpha:1.0];
    }
    [sender performSelector:@selector(setMinimumTrackTintColor:) withObject:sliderColor];
    [sender performSelector:@selector(setMaximumTrackTintColor:) withObject:sliderColor];
    //[sender setThumbTintColor:sliderColor];

}

- (void) setSliderData:(id) sender {
    NSString *key;
    if ([self.overallSlider isEqual:sender]) {
        key = @"overall";
    }
    else if ([self.sleepSlider isEqual:sender]) {
        key = @"sleep";
    }
    else if ([self.energySlider isEqual:sender]) {
        key = @"energy";
    }
    else if ([self.healthSlider isEqual:sender]) {
        key = @"health";
    }
    
    NSNumber *sliderValue = [NSNumber numberWithFloat:[(UISlider *)sender value]];
    [self.detailItem setValue:sliderValue forKey:key];
    [self saveContext];
}

- (void) saveContext { // Save data to the database
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
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
    else if ([segue.identifier isEqualToString:@"chartView"]) {
        // iPad Only
        [[segue destinationViewController] setManagedObjectContext:self.detailItem.managedObjectContext];
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
    [self pressedDoneButton:self];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        // iPad
        if ([self.expandButton.titleLabel.text isEqual:@"Edit"]) {
            [self.expandButton setTitle:@"Done" forState:UIControlStateNormal];
            self.detailItem.editing = [NSNumber numberWithBool:YES];
            [self.myMoodCollectionViewController refresh];
        }
        else {
            [self.expandButton setTitle:@"Edit" forState:UIControlStateNormal];
            self.detailItem.editing = [NSNumber numberWithBool:NO];
            [self.myMoodCollectionViewController refresh];
        }
        [self setVisibilityofNoMoodsLabel];
    }
    else { // iPhone
        // On the iPhone I have a segue to a modal view, so I don't change the button text
   }
    
    [self saveContext];
}

- (void) setVisibilityofNoMoodsLabel {
    BOOL shouldHideLabel = YES;
    if (self.moodListTextView.text.length == 0) {
            shouldHideLabel = NO; // Should only show if there are no moods selected
    }
    [self.noMoodsLabel setHidden:shouldHideLabel];
}

// TODO: Trying to get the gap to disappear when hiding a static table section
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    CGSize textViewSize;
    UIInterfaceOrientation orientation;
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (indexPath.section) {
        case CALENDAR: //Calendar
            height = 65.0;
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
       case MOODS: //Moods
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
        case SLIDERS: //Sliders
            if (self.detailItem.sliderValuesSet.boolValue) {
                height = 0.0;
            }
            else {
                height = 35.0;
                if (indexPath.row == 4) { // Set button
                    height = 46.0;
                }
           }
            break;
        case SLIDERSCHART: //Sliders Chart
            if (self.detailItem.sliderValuesSet.boolValue) {
                height = 140.0;
                if (indexPath.row == 1) { // Adjust button
                    height = 46.0;
                }
            } else {
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
    [self setOverallSlider:nil];
    [super viewDidUnload];
}
@end
