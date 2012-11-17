//
//  MlDetailViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlMoodCollectionViewController.h"

@interface MlDetailViewController : UIViewController <UISplitViewControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *entryLogTextView;
@property (weak, nonatomic) IBOutlet UINavigationItem *detailToolBar;
@property (weak, nonatomic) IBOutlet UISlider *sleepSlider;
@property (weak, nonatomic) IBOutlet UISlider *energySlider;
@property (weak, nonatomic) IBOutlet UISlider *healthSlider;
@property (weak, nonatomic) IBOutlet UIView *moodContainer;
@property (weak, nonatomic) IBOutlet UIButton *sortABCButton;

@property (weak, nonatomic) MlMoodCollectionViewController *myMoodCollectionViewController;
@property (weak, nonatomic) IBOutlet UIButton *SortCBAButton;
@property (weak, nonatomic) IBOutlet UIButton *sortShuffleButton;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)pressedDoneButton:(id)sender;
- (IBAction)moveSleepSlider:(id)sender;
- (IBAction)moveEnergySlider:(id)sender;
- (IBAction)moveHealthSlider:(id)sender;
- (IBAction)sortABC:(id)sender;
- (IBAction)sortCBA:(id)sender;
- (IBAction)sortShuffle:(id)sender;

@property (strong, nonatomic) id detailItem;

@end
