//
//  MlNotificationsTableViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/15/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlNotificationsTableViewController.h"
#import "MlAppDelegate.h"
#import "MlQuietHoursTableViewController.h"
#import "MlReminderTimeTableViewController.h"
#import "Prefs.h"

@interface MlNotificationsTableViewController ()

@end

@implementation MlNotificationsTableViewController

NSUserDefaults *defaults;
BOOL debugging;

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
    defaults = [NSUserDefaults standardUserDefaults];
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
    
    debugging = [  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Debugging"] integerValue];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");

    self.remindersTime0 = (NSDate *)[defaults objectForKey:@"RemindersTime0"];
    self.reminderTime0Switch.on = [defaults boolForKey:@"RemindersTime0On"];
    self.reminderTime0Label.text = [dateFormatter stringFromDate: self.remindersTime0];
    self.reminderTime0Label.enabled = self.reminderTime0Switch.on;

    self.remindersTime1 = (NSDate *)[defaults objectForKey:@"RemindersTime1"];
    self.reminderTime1Switch.on = [defaults boolForKey:@"RemindersTime1On"];
    self.reminderTime1Label.text = [dateFormatter stringFromDate: self.remindersTime1];
    self.reminderTime1Label.enabled = self.reminderTime1Switch.on;

    self.remindersTime2 = (NSDate *)[defaults objectForKey:@"RemindersTime2"];
    self.reminderTime2Switch.on = [defaults boolForKey:@"RemindersTime2On"];
    self.reminderTime2Label.text = [dateFormatter stringFromDate: self.remindersTime2];
    self.reminderTime2Label.enabled = self.reminderTime2Switch.on;
    
    self.remindersTime3 = (NSDate *)[defaults objectForKey:@"RemindersTime3"];
    self.reminderTime3Switch.on = [defaults boolForKey:@"RemindersTime3On"];
    self.reminderTime3Label.text = [dateFormatter stringFromDate: self.remindersTime3];
    self.reminderTime3Label.enabled = self.reminderTime3Switch.on;

    self.remindersTime4 = (NSDate *)[defaults objectForKey:@"RemindersTime4"];
    self.reminderTime4Switch.on = [defaults boolForKey:@"RemindersTime4On"];
    self.reminderTime4Label.text = [dateFormatter stringFromDate: self.remindersTime4];
    self.reminderTime4Label.enabled = self.reminderTime4Switch.on;

    self.remindersTime5 = (NSDate *)[defaults objectForKey:@"RemindersTime5"];
    self.reminderTime5Switch.on = [defaults boolForKey:@"RemindersTime5On"];
    self.reminderTime5Label.text = [dateFormatter stringFromDate: self.remindersTime5];
    self.reminderTime5Label.enabled = self.reminderTime5Switch.on;

    self.randomReminderSwitch.on = [defaults boolForKey:@"DefaultRandomRemindersOn"];
    self.quietStart = (NSDate *)[defaults objectForKey:@"DefaultRandomQuietStartTime"];
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
    [self setStateOfRandomRemindersUI:self.randomReminderSwitch.on];
    
    [self listScheduledNotifications];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeReminderSwitchState:(id)sender {
    long tag = [(UISwitch *)sender tag]; // Tag is set in Interface Builder
    NSLog(@"Sender: %ld", tag );
    switch (tag) {
        case 0:
            [defaults setBool:self.reminderTime0Switch.on forKey:@"RemindersTime0On"];
            self.reminderTime0Label.enabled = self.reminderTime0Switch.on;
            break;
        case 1:
            [defaults setBool:self.reminderTime1Switch.on forKey:@"RemindersTime1On"];
            self.reminderTime1Label.enabled = self.reminderTime1Switch.on;
            break;
        case 2:
            [defaults setBool:self.reminderTime2Switch.on forKey:@"RemindersTime2On"];
            self.reminderTime2Label.enabled = self.reminderTime2Switch.on;
            break;
        case 3:
            [defaults setBool:self.reminderTime3Switch.on forKey:@"RemindersTime3On"];
            self.reminderTime3Label.enabled = self.reminderTime3Switch.on;
            break;
        case 4:
            [defaults setBool:self.reminderTime4Switch.on forKey:@"RemindersTime4On"];
            self.reminderTime4Label.enabled = self.reminderTime4Switch.on;
            break;
        case 5:
            [defaults setBool:self.reminderTime5Switch.on forKey:@"RemindersTime5On"];
            self.reminderTime5Label.enabled = self.reminderTime5Switch.on;
            break;
        default:
            break;
    }
    [self updateRepeatingDateNotifications];
    [defaults synchronize];
}

- (IBAction)changeRandomReminderSwitchState:(id)sender {
    [defaults setBool:self.randomReminderSwitch.on forKey:@"DefaultRandomRemindersOn"];
    [defaults synchronize];
    [self setStateOfRandomRemindersUI:self.randomReminderSwitch.on];
}

- (void) setStateOfRandomRemindersUI: (BOOL) state {
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
    [defaults setInteger:self.reminderStepper.value forKey:@"DefaultRandomTimesPerDay"];
    [defaults synchronize];
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
    [defaults setInteger:self.reminderMinutesStepper.value forKey:@"DefaultDelayMinutes"];
    [defaults synchronize];
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

- (IBAction)pressAddButton:(id)sender {
    // Add a row allowing user to set a time for an alarm, along with an on|off switch
    // Not implemented in 1.0
}


- (IBAction)setMinutesTimerButton:(id)sender {
    [self setNotificationSeconds:[self.reminderMinutesCount.text integerValue]*60];
}

- (IBAction)pressButtonOfDoom:(id)sender {
    UILocalNotification *myLocalNotification = [[UILocalNotification alloc] init];
    if (myLocalNotification == nil) return;
    [self setNotificationSeconds:5]; // 5 seconds from now
}

- (void) updateRepeatingDateNotifications {
    if (self.reminderTime0Switch.on) {
        [self cancelNotificationMatchingTime: self.remindersTime0];
        [self setRepeatingDateNotification:self.remindersTime0];
    }
    else {
        [self cancelNotificationMatchingTime: self.remindersTime0];
    }
    
    if (self.reminderTime1Switch.on) {
        [self cancelNotificationMatchingTime: self.remindersTime1];
        [self setRepeatingDateNotification:self.remindersTime1];
    }
    else {
        [self cancelNotificationMatchingTime: self.remindersTime1];
    }
    
    if (self.reminderTime2Switch.on) {
        [self cancelNotificationMatchingTime: self.remindersTime2];
        [self setRepeatingDateNotification:self.remindersTime2];
    }
    else {
        [self cancelNotificationMatchingTime: self.remindersTime2];
    }

    if (self.reminderTime3Switch.on) {
        [self cancelNotificationMatchingTime: self.remindersTime3];
        [self setRepeatingDateNotification:self.remindersTime3];
    }
    else {
        [self cancelNotificationMatchingTime: self.remindersTime3];
    }

    if (self.reminderTime4Switch.on) {
        [self cancelNotificationMatchingTime: self.remindersTime4];
        [self setRepeatingDateNotification:self.remindersTime4];
    }
    else {
        [self cancelNotificationMatchingTime: self.remindersTime4];
    }

    if (self.reminderTime5Switch.on) {
        [self cancelNotificationMatchingTime: self.remindersTime5];
        [self setRepeatingDateNotification:self.remindersTime5];
    }
    else {
        [self cancelNotificationMatchingTime: self.remindersTime5];
    }
}


- (void) setRepeatingDateNotification: (NSDate *)date {
    UILocalNotification *myLocalNotification = [[UILocalNotification alloc] init];
    if (myLocalNotification == nil) return;
    myLocalNotification.fireDate = date;
    myLocalNotification.timeZone = [NSTimeZone localTimeZone];
    myLocalNotification.repeatInterval = kCFCalendarUnitDay;
    myLocalNotification.alertBody = NSLocalizedString(@"How are you feeling in this moment?", @"Text of the timer alert");
    myLocalNotification.alertAction = NSLocalizedString(@"Launch Mood Log", @"Button text for timer alert");
    myLocalNotification.soundName = @"guitar_sound.caf";
    ((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount = 1;
    myLocalNotification.applicationIconBadgeNumber = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount;
    [[UIApplication sharedApplication] scheduleLocalNotification:myLocalNotification];
    [self listScheduledNotifications];
}

- (void) setNotificationSeconds: (NSTimeInterval)seconds {
    UILocalNotification *myLocalNotification = [[UILocalNotification alloc] init];
    if (myLocalNotification == nil) return;
    NSDate *fireTime = [[NSDate date] dateByAddingTimeInterval:seconds];
    myLocalNotification.fireDate = fireTime;
    myLocalNotification.timeZone = [NSTimeZone localTimeZone];
    myLocalNotification.alertBody = NSLocalizedString(@"How are you feeling in this moment?", @"Text of the timer alert");
    myLocalNotification.alertAction = NSLocalizedString(@"Launch Mood Log", @"Button text for timer alert");
    myLocalNotification.soundName = @"guitar_sound.caf";
    myLocalNotification.applicationIconBadgeNumber = ++((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount;
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

- (void)cancelNotificationMatchingTime: (NSDate *)date {
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = NSLocalizedString(@"h:mm:ss a V", @"h:mm:ss a V date format");
    NSString *dateString = [dateFormatter stringFromDate:date];
    if (notifications.count > 0) {
        for (UILocalNotification *item in notifications) {
            NSString *notificationDateString = [dateFormatter stringFromDate:[item fireDate]];
            if (([item repeatInterval]==kCFCalendarUnitDay) && [dateString isEqualToString:notificationDateString]) {
                [[UIApplication sharedApplication] cancelLocalNotification:item];
            }
        }
    }
    else {
        self.scheduledNotificationsList.text = NSLocalizedString(@"No reminders scheduled", @"This string used for debugging");
    }
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
    else if ([[segue identifier] isEqualToString:@"reminderTime0"]) {
        MlReminderTimeTableViewController *myRemindersTime0Controller = [segue destinationViewController];
        myRemindersTime0Controller.detailItem = self;
        myRemindersTime0Controller.itemNumber = [NSNumber numberWithInt:0];
    }
    else if ([[segue identifier] isEqualToString:@"reminderTime1"]) {
        MlReminderTimeTableViewController *myRemindersTime1Controller = [segue destinationViewController];
        myRemindersTime1Controller.detailItem = self;
        myRemindersTime1Controller.itemNumber = [NSNumber numberWithInt:1];
    }
    else if ([[segue identifier] isEqualToString:@"reminderTime2"]) {
        MlReminderTimeTableViewController *myRemindersTime2Controller = [segue destinationViewController];
        myRemindersTime2Controller.detailItem = self;
        myRemindersTime2Controller.itemNumber = [NSNumber numberWithInt:2];
    }
    else if ([[segue identifier] isEqualToString:@"reminderTime3"]) {
        MlReminderTimeTableViewController *myRemindersTime3Controller = [segue destinationViewController];
        myRemindersTime3Controller.detailItem = self;
        myRemindersTime3Controller.itemNumber = [NSNumber numberWithInt:3];
    }
    else if ([[segue identifier] isEqualToString:@"reminderTime4"]) {
        MlReminderTimeTableViewController *myRemindersTime4Controller = [segue destinationViewController];
        myRemindersTime4Controller.detailItem = self;
        myRemindersTime4Controller.itemNumber = [NSNumber numberWithInt:4];
    }
    else if ([[segue identifier] isEqualToString:@"reminderTime5"]) {
        MlReminderTimeTableViewController *myRemindersTime5Controller = [segue destinationViewController];
        myRemindersTime5Controller.detailItem = self;
        myRemindersTime5Controller.itemNumber = [NSNumber numberWithInt:5];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger sections = 1;
    if (debugging) {
        sections = 4;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = 0;
    switch (section) {
        case 0: // Ask me about my mood at
            rows = 6;
            break;
        case 1: // Debugging
            rows = 1;
            break;
        case 2:
            rows = 1;
            break;
        case 3:
            rows = 2;
            break;
        default:
            break;
    }
    return rows;
}

@end
