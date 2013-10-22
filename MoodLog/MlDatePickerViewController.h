//
//  MlDatePickerViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/6/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlDetailViewController.h"

@interface MlDatePickerViewController : UIViewController
@property (strong, nonatomic) NSDate *dateToSet;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) MlDetailViewController *detailViewController;

- (IBAction)datePicked:(id)sender;

@end
