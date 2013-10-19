//
//  MlReminderTimeTableViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/18/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlNotificationsTableViewController.h"

@interface MlReminderTimeTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (strong, atomic) NSNumber *itemNumber;
@property (strong, atomic) MlNotificationsTableViewController *detailItem;

- (IBAction)setTime:(id)sender;

@end
