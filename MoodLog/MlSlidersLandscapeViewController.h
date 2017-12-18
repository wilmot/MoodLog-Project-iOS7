//
//  MlSlidersLandscapeViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/14/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>
#import "MlDetailViewController.h"
#import "MoodLogEvents.h"

@interface MlSlidersLandscapeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *moodSlider;
@property (weak, nonatomic) IBOutlet UISlider *stressSlider;
@property (weak, nonatomic) IBOutlet UISlider *energySlider;
@property (weak, nonatomic) IBOutlet UISlider *thoughtsSlider;
@property (weak, nonatomic) IBOutlet UISlider *healthSlider;
@property (weak, nonatomic) IBOutlet UISlider *sleepSlider;
@property (weak, nonatomic) IBOutlet MlChartDrawingView *chartDrawingView;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@property (strong, nonatomic) MoodLogEvents *detailItem;

- (IBAction)moveSlider:(id) sender;
- (IBAction)setSliderData:(id)sender;
- (void) configureView;

@end
