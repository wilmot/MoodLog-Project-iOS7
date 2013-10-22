//
//  MlWelcomePageViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/20/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>

@interface MlWelcomePageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageControl *pageControl;

- (IBAction)pressDoneButton:(id)sender;
@end
