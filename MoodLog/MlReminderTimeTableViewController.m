//
//  MlReminderTimeTableViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/18/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlReminderTimeTableViewController.h"

@interface MlReminderTimeTableViewController ()

@end

@implementation MlReminderTimeTableViewController

NSDate *initialDate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    switch ([self.itemNumber integerValue]) {
        case 0:
            [self.timePicker setDate:self.detailItem.remindersTime0];
            break;
        case 1:
            [self.timePicker setDate:self.detailItem.remindersTime1];
            break;
        case 2:
            [self.timePicker setDate:self.detailItem.remindersTime2];
            break;
        default:
            break;
    }
    initialDate = [self.timePicker date];
}

- (void)viewWillDisappear:(BOOL)animated {
    switch ([self.itemNumber integerValue]) {
        case 0:
            [self.detailItem setRepeatingDateNotification:self.detailItem.remindersTime0];
            [self.detailItem cancelNotificationMatchingTime:initialDate];
            [self.detailItem updateRepeatingDateNotifications];
            break;
        case 1:
            [self.detailItem setRepeatingDateNotification:self.detailItem.remindersTime1];
            [self.detailItem cancelNotificationMatchingTime:initialDate];
            [self.detailItem updateRepeatingDateNotifications];
           break;
        case 2:
            [self.detailItem setRepeatingDateNotification:self.detailItem.remindersTime2];
            [self.detailItem cancelNotificationMatchingTime:initialDate];
            [self.detailItem updateRepeatingDateNotifications];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setTime:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch ([self.itemNumber integerValue]) {
        case 0:
            self.detailItem.remindersTime0 = self.timePicker.date;
            self.detailItem.reminderTime0Switch.on = YES;
            [defaults setObject:self.detailItem.remindersTime0 forKey:@"RemindersTime0"];
            [defaults setBool:self.detailItem.reminderTime0Switch.on forKey:@"RemindersTime0On"];
            break;
        case 1:
            self.detailItem.remindersTime1 = self.timePicker.date;
            self.detailItem.reminderTime1Switch.on = YES;
            [defaults setObject:self.detailItem.remindersTime1 forKey:@"RemindersTime1"];
            [defaults setBool:self.detailItem.reminderTime1Switch.on forKey:@"RemindersTime1On"];
            break;
        case 2:
            self.detailItem.remindersTime2 = self.timePicker.date;
            self.detailItem.reminderTime2Switch.on = YES;
            [defaults setObject:self.detailItem.remindersTime2 forKey:@"RemindersTime2"];
            [defaults setBool:self.detailItem.reminderTime2Switch.on forKey:@"RemindersTime2On"];
            break;
        default:
            break;
    }
    [defaults synchronize];
}

@end
