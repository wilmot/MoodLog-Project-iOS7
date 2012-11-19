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
    mood.header = [NSString stringWithFormat:@"%d", ([components year] * 1000) + [components month]];
    
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.detailViewController configureView]; // update the displayed values in the view
}

@end
