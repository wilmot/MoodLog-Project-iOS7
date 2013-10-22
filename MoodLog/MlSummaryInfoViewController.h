//
//  MlSummaryInfoViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 9/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>
#import "MlMasterViewController.h"
#import "MlChartDrawingView.h"

@interface MlSummaryInfoViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerByDate;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerByCategory;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerByEmotion;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) MlMasterViewController *masterViewController;
@property (weak, nonatomic) IBOutlet MlChartDrawingView *pieChartForSummary;
@property (weak, nonatomic) IBOutlet MlChartDrawingView *barChartForSummary;
@property (weak, nonatomic) IBOutlet UITextView *summaryText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewInsideScrollView;
@property(nonatomic, assign) BOOL showSummary;


- (void)summaryInformationQuick: (id)sender;
- (void)summaryInformationSlow: (id)sender;

@end
