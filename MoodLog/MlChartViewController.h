//
//  MlChartViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlChartCollectionViewController.h"

@interface MlChartViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIView *chartContainer;
@property (weak, nonatomic) IBOutlet UIView *summaryView;

- (IBAction)pressDone:(id)sender;
- (IBAction)chooseSegment:(id)sender;

@property (weak, nonatomic) MlChartCollectionViewController *myChartCollectionViewController;

@end
