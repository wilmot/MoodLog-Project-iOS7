//
//  MlDetailViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlDetailViewController.h"
#import "MlMoodCollectionViewController.h"
#import "MlDatePickerViewController.h"

@interface MlDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MlDetailViewController

static MlMoodCollectionViewController *myMoodCollectionViewController;
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
        NSArray *dayNames = @[@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday"];
        
        self.dateLabel.text = [NSString stringWithFormat:@"%d", day];
        self.weekdayLabel.text = [NSString stringWithFormat:@"%@", dayNames[weekday-1]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"h:mm a";
        
        self.detailDescriptionLabel.text = [dateFormatter stringFromDate: today];
        
        dateFormatter.dateFormat = @"MMM YYYY";
        self.monthLabel.text = [dateFormatter stringFromDate: today];
        
        self.entryLogTextView.text = [self.detailItem valueForKey:@"journalEntry"];
        
        // Set the sliders
        [self.sleepSlider setValue:[[self.detailItem valueForKey:@"sleep"] floatValue]];
        [self.energySlider setValue:[[self.detailItem valueForKey:@"energy"] floatValue]];
        [self.healthSlider setValue:[[self.detailItem valueForKey:@"health"] floatValue]];
  
    }
    [self.entryLogTextView setDelegate:self];
    // Hide the Done/Edit button
    [self.detailToolBar setRightBarButtonItem:nil animated:YES];
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
}

- (IBAction)moveSleepSlider:(id)sender {
    [self.detailItem setValue:[NSNumber numberWithFloat:[(UISlider *)sender value]] forKey:@"sleep"];
    [self saveContext];
}

- (IBAction)moveEnergySlider:(id)sender {
    [self.detailItem setValue:[NSNumber numberWithFloat:[(UISlider *)sender value]] forKey:@"energy"];
    [self saveContext];
}

- (IBAction)moveHealthSlider:(id)sender {
    [self.detailItem setValue:[NSNumber numberWithFloat:[(UISlider *)sender value]] forKey:@"health"];
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
        myMoodCollectionViewController = [segue destinationViewController]; // Getting a reference to the collection view
    }
    if ([segue.identifier isEqualToString:@"DatePicker"]) {
        // do stuff around the date & time
        myDatePickerViewController = [segue destinationViewController];
        myDatePickerViewController.detailItem = self.detailItem;
        myDatePickerViewController.dateToSet = [self.detailItem valueForKey:@"date"];
    }
}

- (IBAction)sortABC:(id)sender {
    [self.detailItem setValue:@"Alphabetical" forKey:@"sortStyle"];
    [self saveContext];
    [myMoodCollectionViewController refresh];
}

- (IBAction)sortShuffle:(id)sender {
    [self.detailItem setValue:@"Shuffle" forKey:@"sortStyle"];
    [self saveContext];
    [myMoodCollectionViewController refresh];
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
    [super viewDidUnload];
}
@end
