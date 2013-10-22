//
//  MlChartCollectionViewCell.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/22/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>
#import "MlChartDrawingView.h"
#import "MlChartCollectionViewController.h"
#import "MoodLogEvents.h"

@interface MlChartCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *chartHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *emotionsLabel;
@property (weak, nonatomic) IBOutlet MlChartDrawingView *chartDrawingView;
@property (weak, nonatomic) IBOutlet UILabel *loveLabel;
@property (weak, nonatomic) IBOutlet UILabel *joyLabel;
@property (weak, nonatomic) IBOutlet UILabel *surpriseLabel;
@property (weak, nonatomic) IBOutlet UILabel *angerLabel;
@property (weak, nonatomic) IBOutlet UILabel *sadnessLabel;
@property (weak, nonatomic) IBOutlet UILabel *fearLabel;
@property (strong, nonatomic) MoodLogEvents *detailItem;
@property (strong, nonatomic) MlChartCollectionViewController *myViewController;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;

- (IBAction)pressDetailButton:(id)sender;

@end
