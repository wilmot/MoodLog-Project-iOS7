//
//  MlFacesViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/5/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>
#import "MoodLogEvents.h"
#import "MlMoodCollectionViewController.h"

@interface MlFacesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortStyleSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *toggleFacesButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleColorsButton;
@property (weak, nonatomic) IBOutlet UISlider *fewerMoreSlider;
@property (weak, nonatomic) IBOutlet UIButton *fewerButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *randomizeButton;

@property (strong, nonatomic) MoodLogEvents *detailItem;
@property (weak, nonatomic) MlMoodCollectionViewController *myMoodCollectionViewController;

- (IBAction)toggleFaces:(id)sender;
- (IBAction)toggleColors:(id)sender;
- (IBAction)slideFewerMoreSlider:(id)sender;
- (IBAction)finishedSlidingFewerMoreSlider:(id)sender;
- (IBAction)setFewer:(id)sender;
- (IBAction)setMore:(id)sender;
- (IBAction)selectSegmentForSortStyle:(id)sender;
- (IBAction)rerandomize:(id)sender;

@end
