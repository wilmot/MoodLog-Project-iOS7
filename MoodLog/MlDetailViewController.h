//
//  MlDetailViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlMoodCollectionViewController.h"
#import "MoodLogEvents.h"

@interface MlDetailViewController : UITableViewController <UISplitViewControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *entryLogTextView;
@property (weak, nonatomic) IBOutlet UINavigationItem *detailToolBar;
@property (weak, nonatomic) IBOutlet UISlider *overallSlider;
@property (weak, nonatomic) IBOutlet UISlider *sleepSlider;
@property (weak, nonatomic) IBOutlet UISlider *energySlider;
@property (weak, nonatomic) IBOutlet UISlider *healthSlider;
@property (weak, nonatomic) IBOutlet UIView *moodContainer;
@property (weak, nonatomic) IBOutlet UIButton *sortABCButton;
@property (weak, nonatomic) IBOutlet UIButton *sortGroupButton;
@property (weak, nonatomic) IBOutlet UIButton *SortCBAButton;
@property (weak, nonatomic) IBOutlet UIButton *sortShuffleButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleFacesButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIView *blankCoveringView;
@property (weak, nonatomic) IBOutlet UIButton *expandButton; // edit button
@property (weak, nonatomic) IBOutlet UIView *moodViewWithHeader;
@property (weak, nonatomic) IBOutlet UILabel *noMoodsLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *moodsCell;
@property (weak, nonatomic) IBOutlet UITextView *moodListTextView;

@property (strong, atomic) MlMoodCollectionViewController *myMoodCollectionViewController;
@property (strong, nonatomic) MoodLogEvents *detailItem;


- (IBAction)pressedDoneButton:(id)sender;
- (IBAction)moveSlider:(id) sender;
- (IBAction)setSliderData:(id)sender;
- (IBAction)pressedExpandButton:(id)sender;
- (IBAction)addEntryFromStartScreen:(id)sender;

- (void)configureView;

@end
