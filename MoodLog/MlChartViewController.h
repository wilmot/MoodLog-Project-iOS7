//
//  MlChartViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlChartCollectionViewController.h"

@interface MlChartViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)pressDone:(id)sender;

@property (weak, nonatomic) MlChartCollectionViewController *myChartCollectionViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
