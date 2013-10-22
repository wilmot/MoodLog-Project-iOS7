//
//  MlChartViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlChartCollectionViewController.h"
#import "MlSummaryInfoViewController.h"

@interface MlChartViewController : UIViewController <NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIView *chartContainer;
@property (weak, nonatomic) IBOutlet UIView *summaryView;
@property (weak, nonatomic) IBOutlet UIView *noRecordsView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)pressDone:(id)sender;
- (IBAction)chooseSegment:(id)sender;

@property (weak, nonatomic) MlChartCollectionViewController *myChartCollectionViewController;
@property (weak, nonatomic) MlSummaryInfoViewController *mySummaryInfoViewController;

@end
