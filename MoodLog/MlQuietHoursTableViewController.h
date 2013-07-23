//
//  MlQuietHoursTableViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/22/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlNotificationsTableViewController.h"

@interface MlQuietHoursTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *fromCell;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (strong, atomic) MlNotificationsTableViewController *detailItem;

- (IBAction)setTime:(id)sender;

@end
