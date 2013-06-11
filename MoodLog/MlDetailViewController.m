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
#import "Prefs.h"

@interface MlDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MlDetailViewController

static MlDatePickerViewController *myDatePickerViewController;
NSUserDefaults *defaults;

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
    [self configureView];
    defaults = [NSUserDefaults standardUserDefaults];
}

- (void) viewWillAppear:(BOOL)animated {
    [self configureView];
    if ((self.detailItem.editing.boolValue == NO) && (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)) {
        [self.moodContainer setHidden:NO];
    }
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
        [self.overallSlider setValue:[[self.detailItem valueForKey:@"overall"] floatValue]];
        [self.sleepSlider setValue:[[self.detailItem valueForKey:@"sleep"] floatValue]];
        [self.energySlider setValue:[[self.detailItem valueForKey:@"energy"] floatValue]];
        [self.healthSlider setValue:[[self.detailItem valueForKey:@"health"] floatValue]];
        // Set the slider colors
        [self moveSlider:self.overallSlider];
        [self moveSlider:self.sleepSlider];
        [self moveSlider:self.energySlider];
        [self moveSlider:self.healthSlider ];
        
        [self selectButton]; // Highlight the correct button
        [self setFaces:[self.detailItem.showFaces boolValue]];
        [self setVisibilityofNoMoodsLabel]; // Should only show if there are no moods selected
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            // iPad
            if (self.detailItem.editing.boolValue == YES) {
                [self.expandButton setTitle:@"Done" forState:UIControlStateNormal];
            } else {
                [self.expandButton setTitle:@"Edit" forState:UIControlStateNormal];
            }
        }
        else {
            // iPhone
            if (self.detailItem.editing.boolValue == YES) {
                // Go to the modal mood list
                // The delay gives a chance for the original transition to the detail view to complete
                [self performSelector:@selector(goToEditPanel) withObject:self afterDelay:0.1];
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
}

- (void)goToEditPanel {
    [self performSegueWithIdentifier: @"MoodFullScreenSegue" sender: self];
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

- (void) moveSlider:(id) sender {
    float sliderValue = [[NSNumber numberWithFloat:[(UISlider *)sender value]] floatValue];
    static float previousValue;
    
    if (abs(sliderValue - previousValue) >= 1) {
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

        previousValue = sliderValue;
    }
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
    if ([segue.identifier isEqualToString:@"MoodCollectionSegue"]) {
        self.myMoodCollectionViewController = [segue destinationViewController]; // Getting a reference to the collection view
        ((MlMoodCollectionViewController *)[segue destinationViewController]).detailItem = self.detailItem;
        if ((self.detailItem.editing.boolValue == YES) && (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)) {
            [self.moodContainer setHidden:YES];
        }
    }
    else if ([segue.identifier isEqualToString:@"MoodFullScreenSegue"]) {
        [self pressedDoneButton:self]; // Make sure textfield isn't still in edit mode
        ((MlMoodCollectionViewController *)[segue destinationViewController]).detailItem = self.detailItem;
    }
    else if ([segue.identifier isEqualToString:@"DatePicker"]) {
        // do stuff around the date & time
        myDatePickerViewController = [segue destinationViewController];
        myDatePickerViewController.detailItem = self.detailItem;
        myDatePickerViewController.dateToSet = [self.detailItem valueForKey:@"date"];
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

- (IBAction)sortABC:(id)sender {
    [self setSortStyle:alphabeticalSort];
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)sortGroup:(id)sender {
    [self setSortStyle:groupSort];
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];    
}

- (IBAction)sortCBA:(id)sender {
    [self setSortStyle:reverseAlphabeticalSort];
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)sortShuffle:(id)sender {
    [self setSortStyle:shuffleSort];
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)toggleFaces:(id)sender {
    Boolean facesState = ![self.detailItem.showFaces boolValue];
    [self setFaces:facesState];
    [defaults setBool:facesState forKey:@"DefaultFacesState"];
    [defaults synchronize];

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
    int sections = self.myMoodCollectionViewController.collectionView.numberOfSections;
    if ([self.expandButton.titleLabel.text isEqual:@"Edit"]) {
        [self.noMoodsLabel setHidden:NO];
        for (int i=0; i < sections; i++) {
            if ([self.myMoodCollectionViewController.collectionView numberOfItemsInSection:i ] > 0) {
                [self.noMoodsLabel setHidden:YES]; // Should only show if there are no moods selected
                break;
            }
        }
    }
    else {
        [self.noMoodsLabel setHidden:YES];    
    }
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
        [self.sortGroupButton setSelected:NO];
        [self.sortShuffleButton setSelected:NO];
    }
    else if ([aButton isEqualToString:reverseAlphabeticalSort]) {
        [self.sortABCButton setSelected:NO];
        [self.SortCBAButton setSelected:YES];
        [self.sortGroupButton setSelected:NO];
        [self.sortShuffleButton setSelected:NO];
        
    }
    else if ([aButton isEqualToString:groupSort]) {
        [self.sortABCButton setSelected:NO];
        [self.SortCBAButton setSelected:NO];
        [self.sortGroupButton setSelected:YES];
        [self.sortShuffleButton setSelected:NO];
        
    }
    else if ([aButton isEqualToString:shuffleSort]) {
        [self.sortABCButton setSelected:NO];
        [self.SortCBAButton setSelected:NO];
        [self.sortGroupButton setSelected:NO];
        [self.sortShuffleButton setSelected:YES];
    }
    [defaults setObject:aButton forKey:@"DefaultSortStyle"];
    [defaults synchronize];
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
    [self setSortGroupButton:nil];
    [self setNoMoodsLabel:nil];
    [self setOverallSlider:nil];
    [super viewDidUnload];
}
@end
