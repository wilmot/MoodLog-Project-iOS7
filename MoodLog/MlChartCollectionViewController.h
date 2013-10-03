//
//  MlChartCollectionViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/21/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlChartCellEntryViewController.h"
#import "MoodLogEvents.h"

@interface MlChartCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *chartCollectionView;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSString *chartType;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) MoodLogEvents *detailItem;

@property (weak, nonatomic) MlChartCellEntryViewController *myChartCellEntryViewController;


- (void) setCellType: (id)sender;

@end
