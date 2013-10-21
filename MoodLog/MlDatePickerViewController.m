//
//  MlDatePickerViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/6/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlDatePickerViewController.h"
#import "MlDetailViewController.h"
#import "MoodLogEvents.h"

@interface MlDatePickerViewController ()

@end

@implementation MlDatePickerViewController

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
    [self.datePicker setDate:self.dateToSet animated:YES];
    [self.datePicker setMaximumDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDatePicker:nil];
    [super viewDidUnload];
}
- (IBAction)datePicked:(id)sender {
    MoodLogEvents *mood = (MoodLogEvents *) self.detailItem;

    mood.date = self.datePicker.date;
    // ((year * 1000) + month) -- store the header in a language-agnostic way
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:mood.date];
    mood.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
    
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving Mood Log data", @"Core data saving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to student@voyageropen.org", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
    }
    
    [self.detailViewController configureView]; // update the displayed values in the view
}

@end
