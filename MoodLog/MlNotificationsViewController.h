//
//  MlNotificationsViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/15/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MlNotificationsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *reminderCount;
@property (weak, nonatomic) IBOutlet UIStepper *reminderStepper;

- (IBAction)pressDoneButton:(id)sender;
- (IBAction)incrementReminders:(id)sender;
@end
