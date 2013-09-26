//
//  MlWelcomePageViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/20/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MlWelcomePageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageControl *pageControl;

- (IBAction)pressDoneButton:(id)sender;
@end
