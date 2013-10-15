//
//  MlFactorsViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/14/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlSlidersViewController.h"
#import "MlSlidersLandscapeViewController.h"
#import "MoodLogEvents.h"

@interface MlFactorsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *landscapeContainer;
@property (weak, nonatomic) IBOutlet UIView *portraitContainer;
@property (strong, nonatomic) MlSlidersViewController *portraitController;
@property (strong, nonatomic) MlSlidersLandscapeViewController *landscapeController;

@property (strong, nonatomic) MoodLogEvents *detailItem;

@end
