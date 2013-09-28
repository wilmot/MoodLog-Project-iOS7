//
//  MlSummaryInfoViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 9/24/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlMasterViewController.h"

@interface MlSummaryInfoViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController2;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) MlMasterViewController *masterViewController;
@property (weak, nonatomic) IBOutlet UITextView *summaryText;
@property(nonatomic, assign) BOOL showSummary;


- (void)summaryInformationQuick: (id)sender;
- (void)summaryInformationSlow: (id)sender;

@end
