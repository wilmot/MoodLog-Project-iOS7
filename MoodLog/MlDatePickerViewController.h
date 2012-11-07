//
//  MlDatePickerViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/6/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MlDatePickerViewController : UIViewController
@property (strong, nonatomic) NSDate *dateToSet;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) id detailItem;

- (IBAction)datePicked:(id)sender;

@end
