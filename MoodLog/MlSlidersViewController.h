//
//  MlSlidersViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/12/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlDetailViewController.h"

@interface MlSlidersViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *moodSlider;
@property (weak, nonatomic) IBOutlet UISlider *stressSlider;
@property (weak, nonatomic) IBOutlet UISlider *energySlider;
@property (weak, nonatomic) IBOutlet UISlider *thoughtsSlider;
@property (weak, nonatomic) IBOutlet UISlider *healthSlider;
@property (weak, nonatomic) IBOutlet UISlider *sleepSlider;
@property (weak, nonatomic) IBOutlet MlChartDrawingView *chartDrawingView;

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) MlDetailViewController *detailViewController;

- (IBAction)moveSlider:(id) sender;
- (IBAction)setSliderData:(id)sender;

@end
