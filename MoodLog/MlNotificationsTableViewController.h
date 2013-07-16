//
//  MlNotificationsTableViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/15/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MlNotificationsTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *reminderCount;
@property (weak, nonatomic) IBOutlet UIStepper *reminderStepper;
@property (weak, nonatomic) IBOutlet UITextField *reminderMinutesCount;
@property (weak, nonatomic) IBOutlet UIStepper *reminderMinutesStepper;

- (IBAction)pressDoneButton:(id)sender;
- (IBAction)incrementReminders:(id)sender;
- (IBAction)incrementMinuteStepper:(id)sender;
@end
