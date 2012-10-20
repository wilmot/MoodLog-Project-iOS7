//
//  MlDetailViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlDetailViewController.h"

@interface MlDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation MlDetailViewController

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

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSDate *today = [self.detailItem valueForKey:@"dateCreated"];
        
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
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (IBAction)moveEnergySlider:(id)sender {
    [self.detailItem setValue:[NSNumber numberWithFloat:[(UISlider *)sender value]] forKey:@"energy"];
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (IBAction)moveHealthSlider:(id)sender {
    [self.detailItem setValue:[NSNumber numberWithFloat:[(UISlider *)sender value]] forKey:@"health"];
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
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
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
