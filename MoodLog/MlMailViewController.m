//
//  MlMailViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlMailViewController.h"

@interface MlMailViewController ()

@end

@implementation MlMailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self updateDateRangeDrawing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidUnload {
    [self setStartSlider:nil];
    [self setEndSlider:nil];
    [self setAllButton:nil];
    [self setMonthButton:nil];
    [self setWeekButton:nil];
    [self setLatestButton:nil];
    [self setDateRangeDrawing:nil];
    [self setDateRangeDrawing:nil];
    [super viewDidUnload];
}
- (IBAction)pressAllButton:(id)sender {
    self.startSlider.value = 0.0;
    self.endSlider.value = 1.0;
    [self updateDateRangeDrawing];
}

- (IBAction)pressMonthButton:(id)sender {
    self.startSlider.value = 0.5;
    self.endSlider.value = 1.0;
    [self updateDateRangeDrawing];
}

- (IBAction)pressWeekButton:(id)sender {
    self.startSlider.value = 0.9;
    self.endSlider.value = 1.0;
    [self updateDateRangeDrawing];
}

- (IBAction)pressLatestButton:(id)sender {
    self.startSlider.value = 1.0;
    self.endSlider.value = 1.0;
    [self updateDateRangeDrawing];
}

- (IBAction)slideStartSlider:(id)sender {
    if (self.startSlider.value > self.endSlider.value) {
        [self.endSlider setValue:[self.startSlider value]];
    }
    [self updateDateRangeDrawing];
}

- (IBAction)slideEndSlider:(id)sender {
    if (self.endSlider.value < self.startSlider.value) {
        [self.startSlider setValue:[self.endSlider value]];
    }
    [self updateDateRangeDrawing];
}

- (void) updateDateRangeDrawing {
    self.dateRangeDrawing.startValue = [NSNumber numberWithFloat:self.startSlider.value];
    self.dateRangeDrawing.endValue = [NSNumber numberWithFloat:self.endSlider.value];
    [self.dateRangeDrawing setNeedsDisplay];
}

@end
