//
//  MlChartCellEntryViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/25/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>
#import "MoodLogEvents.h"

@interface MlChartCellEntryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) MoodLogEvents *detailItem;

- (IBAction)doneButton:(id)sender;

@end
