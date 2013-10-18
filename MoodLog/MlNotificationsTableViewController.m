//
//  MlNotificationsTableViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/15/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlNotificationsTableViewController.h"
#import "MlAppDelegate.h"
#import "MlQuietHoursTableViewController.h"
#import "Prefs.h"

@interface MlNotificationsTableViewController ()

@end

@implementation MlNotificationsTableViewController

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
    if (self.theNumber == 0) {
        self.theNumber = 1;
    }
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.minutesSetButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.minutesSetButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.buttonOfDoom setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.buttonOfDoom setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.notificationListButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.notificationListButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.clearAllNotificationsButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.clearAllNotificationsButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.reminderSwitch setOn:[defaults boolForKey:@"DefaultRandomRemindersOn"]];
    
    self.quietStart = (NSDate *)[defaults objectForKey:@"DefaultRandomQuietStartTime"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");
    NSString *quietStartString = [dateFormatter stringFromDate: self.quietStart];
    
    self.quietEnd = (NSDate *)[defaults objectForKey:@"DefaultRandomQuietEndTime"];
    NSString *quietEndString = [dateFormatter stringFromDate: self.quietEnd];
    
    self.reminderQuietHoursText2.text = [NSString stringWithFormat:NSLocalizedString(@"Quiet Hours: %@ to %@", @"Quiet Hours: %@ to %@ - Notifications view"),quietStartString, quietEndString];
    
    // Set Random Reminder Times/Day
    self.reminderCount.text = [NSString stringWithFormat:@"%ld",(long)[defaults integerForKey:@"DefaultRandomTimesPerDay"]];
    self.reminderStepper.value = [defaults integerForKey:@"DefaultRandomTimesPerDay"];
    [self setReminderTimesPerDayLabelText];
    
    // Set Minutes Delay #Times
    self.reminderMinutesCount.text = [NSString stringWithFormat:@"%ld",(long)[defaults integerForKey:@"DefaultDelayMinutes"]];
    self.reminderMinutesStepper.value = [defaults integerForKey:@"DefaultDelayMinutes"];
    [self setReminderMinutesLabelText];
    
    // Set the background for any states you plan to use
    [self setStateOfRemindersUI:self.reminderSwitch.on];
    
    [self listScheduledNotifications];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeReminderSwitchState:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.reminderSwitch.on forKey:@"DefaultRandomRemindersOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setStateOfRemindersUI:self.reminderSwitch.on];

}

- (void) setStateOfRemindersUI: (BOOL) state {
    self.reminderInitialText.enabled = state;
    self.reminderMinutesCount.enabled = state;
    self.timesPerDayText.enabled = state;
    self.reminderStepper.enabled = state;
    self.reminderQuietHoursText1.enabled = state;
    self.reminderQuietHoursText2.enabled = state;
}

- (IBAction)incrementReminders:(id)sender {
    self.reminderCount.text = [NSString stringWithFormat:@"%d",(int)round(self.reminderStepper.value)];
    [self setReminderTimesPerDayLabelText];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.reminderStepper.value forKey:@"DefaultRandomTimesPerDay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setReminderTimesPerDayLabelText {
    if (self.reminderStepper.value == 1) {
        self.timesPerDayText.text = NSLocalizedString(@"Time/Day", @"Time/Day -- when only one time given");
    }
    else {
        self.timesPerDayText.text = NSLocalizedString(@"Times/Day", @"Times/Day");
    }
}

- (IBAction)incrementMinuteStepper:(id)sender {
    self.reminderMinutesCount.text = [NSString stringWithFormat:@"%d",(int)round(self.reminderMinutesStepper.value)];
    [self setReminderMinutesLabelText];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.reminderMinutesStepper.value forKey:@"DefaultDelayMinutes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setReminderMinutesLabelText {
    if (self.reminderMinutesStepper.value == 1) {
        self.minutesTimerText.text = NSLocalizedString(@"Minute", @"Minute - singular");
    }
    else {
        self.minutesTimerText.text = NSLocalizedString(@"Minutes", @"Minutes");
    }
}

- (IBAction)pressDoneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)setMinutesTimerButton:(id)sender {
    [self setNotificationSeconds:[self.reminderMinutesCount.text integerValue]*60];
}

- (IBAction)pressButtonOfDoom:(id)sender {
    UILocalNotification *myLocalNotification = [[UILocalNotification alloc] init];
    if (myLocalNotification == nil) return;
    [self setNotificationSeconds:5]; // 5 seconds from now
}

- (void) setNotificationSeconds: (NSTimeInterval)seconds {
    UILocalNotification *myLocalNotification = [[UILocalNotification alloc] init];
    if (myLocalNotification == nil) return;
    NSDate *fireTime = [[NSDate date] dateByAddingTimeInterval:seconds];
    myLocalNotification.fireDate = fireTime;
    myLocalNotification.timeZone = [NSTimeZone localTimeZone];
    myLocalNotification.alertBody = NSLocalizedString(@"How are you feeling in this moment?", @"Text of the timer alert");
    myLocalNotification.alertAction = NSLocalizedString(@"New Mood Log Entry", @"Button text for timer alert");
    myLocalNotification.soundName = @"guitar_sound.caf";
    myLocalNotification.applicationIconBadgeNumber = ++((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount;
    NSLog(@"Setting Badge #=%ld, badgeCount: %ld",(long)((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount, (long)myLocalNotification.applicationIconBadgeNumber);
    [[UIApplication sharedApplication] scheduleLocalNotification:myLocalNotification];
    [self listScheduledNotifications];
}

- (IBAction)pressNotificationListButton:(id)sender {
    [self listScheduledNotifications];
}

- (IBAction)pressClearAllNotificationsButton:(id)sender {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self listScheduledNotifications];
}

-(void)listScheduledNotifications {
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd, YYYY h:mm:ss a V", @"MMMM dd, YYYY h:mm:ss a V date format");
    if (notifications.count > 0) {
        NSMutableString *scheduledItemsString = [[NSMutableString alloc] init];
        for (UILocalNotification *item in notifications) {
            [scheduledItemsString appendFormat:@"%@\n",[dateFormatter stringFromDate:[item fireDate]]];
        }
        self.scheduledNotificationsList.text = scheduledItemsString;
    }
    else {
        self.scheduledNotificationsList.text = NSLocalizedString(@"No reminders scheduled", @"This string used for debugging");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"quietHoursSegue"]) {
        MlQuietHoursTableViewController *myQuietHoursController = [segue destinationViewController];
        myQuietHoursController.detailItem = self;
    }
}

@end
