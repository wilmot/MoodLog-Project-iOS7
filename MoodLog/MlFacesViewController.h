//
//  MlFacesViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/5/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoodLogEvents.h"
#import "MlMoodCollectionViewController.h"

@interface MlFacesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *sortABCButton;
@property (weak, nonatomic) IBOutlet UIButton *sortGroupButton;
@property (weak, nonatomic) IBOutlet UIButton *SortCBAButton;
@property (weak, nonatomic) IBOutlet UIButton *sortShuffleButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleFacesButton;
@property (weak, nonatomic) IBOutlet UISlider *fewerMoreSlider;
@property (weak, nonatomic) IBOutlet UIButton *fewerButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (strong, nonatomic) MoodLogEvents *detailItem;
@property (weak, nonatomic) MlMoodCollectionViewController *myMoodCollectionViewController;

- (IBAction)sortABC:(id)sender;
- (IBAction)sortGroup:(id)sender;
- (IBAction)sortCBA:(id)sender;
- (IBAction)sortShuffle:(id)sender;
- (IBAction)toggleFaces:(id)sender;
- (IBAction)slideFewerMoreSlider:(id)sender;
- (IBAction)finishedSlidingFewerMoreSlider:(id)sender;
- (IBAction)setFewer:(id)sender;
- (IBAction)setMore:(id)sender;

@end
