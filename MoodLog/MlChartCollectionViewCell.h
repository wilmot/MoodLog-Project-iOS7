//
//  MlChartCollectionViewCell.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/22/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlChartDrawingView.h"

@interface MlChartCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *chartHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *emotionsLabel;
@property (weak, nonatomic) IBOutlet MlChartDrawingView *chartDrawingView;

@end
