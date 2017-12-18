//
//  MlMailViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>
#import "MlDateRangeDrawing.h"
#import "MlMasterViewController.h"
#import "MlEmailEventCountDrawing.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface MlMailViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>
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
@property (weak, nonatomic) IBOutlet UIButton *composeButton;
@property (weak, nonatomic) IBOutlet UITextField *recipientList;

// Unused?
@property (weak, nonatomic) IBOutlet MlEmailEventCountDrawing *eventCountView;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) MlMasterViewController *masterViewController;

- (IBAction)doneButton:(id)sender;
- (IBAction)slideStartSlider:(id)sender;
- (IBAction)slideEndSlider:(id)sender;
- (IBAction)finishedSlidingStartSlider:(id)sender;
- (IBAction)finishedSlidingEndSlider:(id)sender;
- (IBAction)pressAllButton:(id)sender;
- (IBAction)pressMonthButton:(id)sender;
- (IBAction)pressWeekButton:(id)sender;
- (IBAction)pressTodayButton:(id)sender;
- (IBAction)pressLatestButton:(id)sender;
- (IBAction)composeEmail:(id)sender;
- (IBAction)updatedRecipientList:(id)sender;
- (IBAction)testCreateNewRecord:(id)sender;
@end
