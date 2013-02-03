//
//  MlDetailViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlDetailViewController.h"
#import "MlDatePickerViewController.h"
#import "Prefs.h"

@interface MlDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MlDetailViewController

static MlDatePickerViewController *myDatePickerViewController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void) viewDidAppear:(BOOL)animated {
    [self configureView];
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
        
        self.entryLogTextView.text = [self.detailItem valueForKey:@"journalEntry"];
        
        // Set the sliders
        [self.sleepSlider setValue:[[self.detailItem valueForKey:@"sleep"] floatValue]];
        [self.energySlider setValue:[[self.detailItem valueForKey:@"energy"] floatValue]];
        [self.healthSlider setValue:[[self.detailItem valueForKey:@"health"] floatValue]];
        // Set the slider colors
        [self moveSlider:@"sleep" sender:self.sleepSlider];
        [self moveSlider:@"energy" sender:self.energySlider];
        [self moveSlider:@"health" sender:self.healthSlider ];
        
        [self selectButton]; // Highlight the correct button
        [self setFaces:[self.detailItem.showFaces boolValue]];
        if (self.detailItem.editing.boolValue == YES) {
            [self.expandButton setTitle:@"Done" forState:UIControlStateNormal];
        } else {
            [self.expandButton setTitle:@"Edit" forState:UIControlStateNormal];
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

- (IBAction)moveSleepSlider:(id)sender {
    [self moveSlider:@"sleep" sender:sender];
    [self setSliderData:@"sleep" sender:sender];
}

- (IBAction)moveEnergySlider:(id)sender {
    [self moveSlider:@"energy" sender:sender];
    [self setSliderData:@"energy" sender:sender];
}

- (IBAction)moveHealthSlider:(id)sender {
    [self moveSlider:@"health" sender:sender];
    [self setSliderData:@"health" sender:sender];
}

- (void) moveSlider:(NSString *)key sender:(id) sender {
    NSNumber *sliderValue = [NSNumber numberWithFloat:[(UISlider *)sender value]];
    
    UIColor *sliderColor;
    if ([sliderValue integerValue] >= 0) { // Tint green
        sliderColor = [UIColor colorWithRed:fabsf(([sliderValue floatValue] - 10.0)/20.0) green:([sliderValue floatValue] + 10.0)/20.0 blue:1.0 - ([sliderValue floatValue] + 10.0)/20.0 alpha:1.0];
    }
    else { // Tint red
        sliderColor = [UIColor colorWithRed:fabsf(([sliderValue floatValue] - 10.0)/20.0) green:([sliderValue floatValue] + 10.0)/20.0 blue:1.0 - fabsf(([sliderValue floatValue] - 10.0)/20.0) alpha:1.0];
    }
    [sender setMinimumTrackTintColor:sliderColor];
    [sender setMaximumTrackTintColor:sliderColor];
    //[sender setThumbTintColor:sliderColor];
}

- (void) setSliderData: (NSString *)key sender:(id) sender {
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
    if ([segue.identifier isEqualToString:@"MoodCollectionSegue"]) {
        self.myMoodCollectionViewController = [segue destinationViewController]; // Getting a reference to the collection view
    }
    if ([segue.identifier isEqualToString:@"DatePicker"]) {
        // do stuff around the date & time
        myDatePickerViewController = [segue destinationViewController];
        myDatePickerViewController.detailItem = self.detailItem;
        myDatePickerViewController.dateToSet = [self.detailItem valueForKey:@"date"];
        myDatePickerViewController.detailViewController = self;
    }
}

- (IBAction)sortABC:(id)sender {
    self.detailItem.sortStyle = alphabeticalSort;
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)sortCBA:(id)sender {
    self.detailItem.sortStyle = reverseAlphabeticalSort;
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)sortShuffle:(id)sender {
    self.detailItem.sortStyle = shuffleSort;
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)toggleFaces:(id)sender {
    [self setFaces:![self.detailItem.showFaces boolValue]];
}

- (IBAction)addEntryFromStartScreen:(id)sender {
    NSLog(@"Adding a new entry");
    
}

- (IBAction)pressedExpandButton:(id)sender {
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
    [self saveContext];
}

- (void) setFaces:(BOOL)facesState {
    if (facesState == YES) {
        self.myMoodCollectionViewController.cellIdentifier = @"moodCellFaces";
    }
    else {
        self.myMoodCollectionViewController.cellIdentifier = @"moodCell";
    }
    self.detailItem.showFaces = [NSNumber numberWithBool:facesState]; // Save state in database
    [self.toggleFacesButton setSelected:facesState];
    [self saveContext];
    [self.myMoodCollectionViewController refresh];
}

- (void) selectButton {
    NSString *aButton = [self.detailItem valueForKey:@"sortStyle"];
    if ([aButton isEqualToString:alphabeticalSort]) {
        [self.sortABCButton setSelected:YES];
        [self.SortCBAButton setSelected:NO];
        [self.sortShuffleButton setSelected:NO];
    }
    else if ([aButton isEqualToString:reverseAlphabeticalSort]) {
        [self.sortABCButton setSelected:NO];
        [self.SortCBAButton setSelected:YES];
        [self.sortShuffleButton setSelected:NO];
        
    }
    else if ([aButton isEqualToString:shuffleSort]) {
        [self.sortABCButton setSelected:NO];
        [self.SortCBAButton setSelected:NO];
        [self.sortShuffleButton setSelected:YES];
    }
}

#pragma mark - Entry Log UITextView delegate methods
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.detailToolBar setRightBarButtonItem:self.doneButton animated:YES];
    [textView resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.detailToolBar setRightBarButtonItem:nil animated:YES];
 
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
    [super viewDidUnload];
}
@end
