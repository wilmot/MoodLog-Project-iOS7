//
//  MlMailViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlDateRangeDrawing.h"

@interface MlMailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *startSlider;
@property (weak, nonatomic) IBOutlet UISlider *endSlider;
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UIButton *weekButton;
@property (weak, nonatomic) IBOutlet UIButton *latestButton;
@property (weak, nonatomic) IBOutlet MlDateRangeDrawing *dateRangeDrawing;
@property (weak, nonatomic) IBOutlet UIButton *composeButton;

- (IBAction)doneButton:(id)sender;
- (IBAction)slideStartSlider:(id)sender;
- (IBAction)slideEndSlider:(id)sender;
- (IBAction)pressAllButton:(id)sender;
- (IBAction)pressMonthButton:(id)sender;
- (IBAction)pressWeekButton:(id)sender;
- (IBAction)pressLatestButton:(id)sender;
- (IBAction)composeEmail:(id)sender;
@end
