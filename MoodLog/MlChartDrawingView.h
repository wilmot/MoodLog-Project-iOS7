//
//  MlChartDrawingView.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/23/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlAppDelegate.h"

@interface MlChartDrawingView : UIView

@property (nonatomic, assign) CGRect barRect;
@property (nonatomic, assign) CGFloat chartHeightOverall;
@property (nonatomic, assign) CGFloat chartHeightSleep;
@property (nonatomic, assign) CGFloat chartHeightHealth;
@property (nonatomic, assign) CGFloat chartHeightEnergy;
@property (nonatomic, assign) CGFloat circumference;
@property (strong, nonatomic) NSString *chartType;
@property (nonatomic, assign) BOOL dividerLine;
@property (strong, nonatomic) NSDictionary *categoryCounts;

@end
