//
//  MlChartViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>
#import "MlChartCollectionViewController.h"
#import "MlSummaryInfoViewController.h"
#import "MlDateRangeDrawing.h"

@interface MlChartViewController : UIViewController <NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *disclosureTriangle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIView *toolsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *eventCounterView;

// Date Range Control
@property (weak, nonatomic) IBOutlet UISlider *startSlider;
@property (weak, nonatomic) IBOutlet UISlider *endSlider;
@property (weak, nonatomic) IBOutlet UILabel *eventCount;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet MlDateRangeDrawing *dateRangeDrawing;
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *monthButton;
@property (weak, nonatomic) IBOutlet UIButton *weekButton;
@property (weak, nonatomic) IBOutlet UIButton *todayButton;
@property (weak, nonatomic) IBOutlet UIButton *latestButton;
@property (strong, nonatomic) IBOutletCollection(id) NSArray *itemsToDisableTogether;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (weak, nonatomic) IBOutlet UIView *chartContainer;
@property (weak, nonatomic) IBOutlet UIView *summaryView;
@property (weak, nonatomic) IBOutlet UIView *noRecordsView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)pressDone:(id)sender;
- (IBAction)chooseSegment:(id)sender;
- (IBAction)toggleControls:(id)sender;

@property (weak, nonatomic) MlChartCollectionViewController *myChartCollectionViewController;
@property (weak, nonatomic) MlSummaryInfoViewController *mySummaryInfoViewController;

@end
