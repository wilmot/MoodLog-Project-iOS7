//
//  MlDatePickerViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/6/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
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
    [self setDatePicker:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)datePicked:(id)sender {
    MoodLogEvents *mood = (MoodLogEvents *) self.detailItem;

    mood.date = self.datePicker.date;
    // ((year * 1000) + month) -- store the header in a language-agnostic way
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:mood.date];
    mood.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
    
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Error saving Mood-Log data", @"Core data saving error alert title")
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
    
    [self.detailViewController configureView]; // update the displayed values in the view
}

@end
