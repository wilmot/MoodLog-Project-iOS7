//
//  MlMasterViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MlDetailViewController;

#import <CoreData/CoreData.h>
#import "MoodLogEvents.h"

@interface MlMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MlDetailViewController *detailViewController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)insertNewObject:(id)sender;
- (MoodLogEvents *) insertNewObjectAndReturnReference: (id) sender;

- (IBAction)showWelcomeScreen:(id)sender;

@end
