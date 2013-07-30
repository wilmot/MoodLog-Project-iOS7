//
//  MlNotificationsTableViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/15/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MlNotificationsTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (weak, nonatomic) IBOutlet UITextField *reminderCount;
@property (weak, nonatomic) IBOutlet UILabel *reminderInitialText;
@property (weak, nonatomic) IBOutlet UIStepper *reminderStepper;
@property (weak, nonatomic) IBOutlet UILabel *reminderQuietHoursText1;
@property (weak, nonatomic) IBOutlet UILabel *reminderQuietHoursText2;
@property (weak, nonatomic) IBOutlet UITextField *reminderMinutesCount;
@property (weak, nonatomic) IBOutlet UIStepper *reminderMinutesStepper;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, assign) NSInteger theNumber;
@property (weak, nonatomic) IBOutlet UILabel *minutesTimerText;
@property (weak, nonatomic) IBOutlet UILabel *timesPerDayText;
@property (weak, nonatomic) IBOutlet UIButton *minutesSetButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonOfDoom;
@property (weak, nonatomic) IBOutlet UIButton *notificationListButton;
@property (weak, nonatomic) IBOutlet UITextView *scheduledNotificationsList;
@property (weak, nonatomic) IBOutlet UIButton *clearAllNotificationsButton;
@property (strong, nonatomic) NSDate *quietStart;
@property (strong, nonatomic) NSDate *quietEnd;

- (IBAction)changeReminderSwitchState:(id)sender;
- (IBAction)incrementReminders:(id)sender;
- (IBAction)incrementMinuteStepper:(id)sender;
- (IBAction)pressButtonOfDoom:(id)sender;
- (IBAction)pressNotificationListButton:(id)sender;
- (IBAction)pressClearAllNotificationsButton:(id)sender;
- (IBAction)setMinutesTimerButton:(id)sender;
- (IBAction)pressDoneButton:(id)sender;
@end
