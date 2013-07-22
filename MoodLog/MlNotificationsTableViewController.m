//
//  MlNotificationsTableViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/15/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlNotificationsTableViewController.h"
#import "MlAppDelegate.h"

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
    // Set the background for any states you plan to use
    [self.minutesSetButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.minutesSetButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.buttonOfDoom setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.buttonOfDoom setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self setStateOfRemindersUI:self.reminderSwitch.on];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeReminderSwitchState:(id)sender {
    [self setStateOfRemindersUI:self.reminderSwitch.on];
}

- (void) setStateOfRemindersUI: (BOOL) state {
    self.reminderInitialText.enabled = state;
    self.reminderMinutesCount.enabled = state;
    self.timesPerDayText.enabled = state;
    self.reminderStepper.enabled = state;
    self.reminderQuietHoursText1.enabled = state;
    self.reminderQuietHoursText2.enabled = state;
    self.reminderQuietHoursText3.enabled = state;

}

- (IBAction)incrementReminders:(id)sender {
    self.reminderCount.text = [NSString stringWithFormat:@"%d",(int)round(self.reminderStepper.value)];
    if (self.reminderStepper.value == 1) {
        self.timesPerDayText.text = @"Time/Day";
    }
    else {
        self.timesPerDayText.text = @"Times/Day";
    }
}

- (IBAction)incrementMinuteStepper:(id)sender {
    self.reminderMinutesCount.text = [NSString stringWithFormat:@"%d",(int)round(self.reminderMinutesStepper.value)];
    if (self.reminderMinutesStepper.value == 1) {
        self.minutesTimerText.text = @"Minute";
    }
    else {
        self.minutesTimerText.text = @"Minutes";
    }
}

- (IBAction)setMinutesTimerButton:(id)sender {
    UILocalNotification *myLocalNotification = [[UILocalNotification alloc] init];
    if (myLocalNotification == nil) return;
    NSDate *fireTime = [[NSDate date] addTimeInterval:[self.reminderMinutesCount.text integerValue]*60];
    myLocalNotification.fireDate = fireTime;
    myLocalNotification.alertBody = @"How are you feeling in this moment?";
    myLocalNotification.alertAction = @"New Mood Log Entry";
    myLocalNotification.soundName = @"guitar_sound.caf";
    NSLog(@"Badge Count: %ld",(long)((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount);
    myLocalNotification.applicationIconBadgeNumber = ++((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount;
    [[UIApplication sharedApplication] scheduleLocalNotification:myLocalNotification];
}

- (IBAction)pressDoneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)pressButtonOfDoom:(id)sender {
    UILocalNotification *myLocalNotification = [[UILocalNotification alloc] init];
    if (myLocalNotification == nil) return;
    NSDate *fireTime = [[NSDate date] addTimeInterval:5]; // adds 5 secs
    myLocalNotification.fireDate = fireTime;
    myLocalNotification.alertBody = @"How are you feeling in this moment?";
    myLocalNotification.alertAction = @"New Mood Log Entry";
    myLocalNotification.soundName = @"guitar_sound.caf";
    NSLog(@"Badge Count: %ld",(long)((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount);
    myLocalNotification.applicationIconBadgeNumber = ++((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount;
    [[UIApplication sharedApplication] scheduleLocalNotification:myLocalNotification];
}

@end
