//
//  MlMasterViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>

@class MlDetailViewController;

#import <CoreData/CoreData.h>
#import "MoodLogEvents.h"

@interface MlMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) MlDetailViewController *detailViewController;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerForEmotions;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *aNewEntryButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *chartButton;
@property (strong, nonatomic) UIView *firstTimeView;

typedef NS_ENUM(NSInteger, SearchTabItem) {
    SearchTabItemAll,
    SearchTabItemEmotions,
    SearchTabItemText
};

- (void)insertNewObject:(id)sender;
- (MoodLogEvents *) insertNewObjectAndReturnReference: (id) sender;

- (IBAction)showWelcomeScreen:(id)sender;
- (IBAction)showCharts:(id)sender;

@end
