//
//  MlSlidersLandscapeViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/14/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlSlidersLandscapeViewController.h"
#import "Prefs.h"

@interface MlSlidersLandscapeViewController ()

@end

@implementation MlSlidersLandscapeViewController

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
    [self configureView];
}

- (void) configureView {
    // Set the sliders
    [self.moodSlider setValue:[[self.detailItem valueForKey:@"overall"] floatValue]];
    [self.stressSlider setValue:[[self.detailItem valueForKey:@"stress"] floatValue]];
    [self.energySlider setValue:[[self.detailItem valueForKey:@"energy"] floatValue]];
    [self.thoughtsSlider setValue:[[self.detailItem valueForKey:@"thoughts"] floatValue]];
    [self.healthSlider setValue:[[self.detailItem valueForKey:@"health"] floatValue]];
    [self.sleepSlider setValue:[[self.detailItem valueForKey:@"sleep"] floatValue]];
    // Set the slider colors
    [self setSliderColor:self.moodSlider];
    [self setSliderColor:self.stressSlider];
    [self setSliderColor:self.energySlider];
    [self setSliderColor:self.thoughtsSlider];
    [self setSliderColor:self.healthSlider ];
    [self setSliderColor:self.sleepSlider];
    
    [self updateChart];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return (UIInterfaceOrientationLandscapeLeft & UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateChart {
    self.chartDrawingView.chartType = @"Bar";
    self.chartDrawingView.chartFontSize = 14.0;
    [self.chartDrawingView setChartHeightOverall:[self.moodSlider value]];
    [self.chartDrawingView setChartHeightStress:[self.stressSlider value]];
    [self.chartDrawingView setChartHeightEnergy:[self.energySlider value]];
    [self.chartDrawingView setChartHeightThoughts:[self.thoughtsSlider value]];
    [self.chartDrawingView setChartHeightHealth:[self.healthSlider value]];
    [self.chartDrawingView setChartHeightSleep:[self.sleepSlider value]];
    self.chartDrawingView.dividerLine = NO;
    [self.chartDrawingView setNeedsDisplay];
}

- (void) moveSlider:(id) sender {
    float sliderValue = (float)[[NSNumber numberWithFloat:[(UISlider *)sender value]] integerValue];
    static float previousValue;
    
    if (fabsf(sliderValue - previousValue) >= 1) {
        [self setSliderColor:sender];
        previousValue = sliderValue;
    }
//    [(UISlider *)sender setValue:sliderValue]; // pin the slider to integral values
    [self updateChart];
}

- (void) setSliderColor:(id) sender {
    float sliderValue = [[NSNumber numberWithFloat:[(UISlider *)sender value]] floatValue];
    UIColor *sliderColor;
    if (sliderValue > 0) { // Tint green
        sliderColor = [UIColor colorWithRed:fabs((sliderValue  - 10.0)/20.0) green:(sliderValue + 10.0)/20.0 blue:1.0 - (sliderValue + 10.0)/20.0 alpha:sliderAlpha];
    }
    else if (sliderValue < 0) { // Tint red
        sliderColor = [UIColor colorWithRed:fabs((sliderValue - 10.0)/20.0) green:(sliderValue + 10.0)/20.0 blue:1.0 - fabs((sliderValue - 10.0)/20.0) alpha:sliderAlpha];
    }
    else { // == 0
        sliderColor = [UIColor whiteColor];
    }
//    [(UISlider *)sender setMaximumTrackTintColor:sliderColor];
//    [(UISlider *)sender setMinimumTrackTintColor:sliderColor];    
    [(UISlider *)sender setBackgroundColor:sliderColor];
}

- (void) setSliderData:(id) sender {
    NSString *key;
    if ([self.moodSlider isEqual:sender]) {
        key = @"overall";
    }
    else if ([self.stressSlider isEqual:sender]) {
        key = @"stress";
    }
    else if ([self.energySlider isEqual:sender]) {
        key = @"energy";
    }
    else if ([self.thoughtsSlider isEqual:sender]) {
        key = @"thoughts";
    }
    else if ([self.healthSlider isEqual:sender]) {
        key = @"health";
    }
    else if ([self.sleepSlider isEqual:sender]) {
        key = @"sleep";
    }
    
    NSNumber *sliderValue = [NSNumber numberWithFloat:[(UISlider *)sender value]];
    [self.detailItem setValue:sliderValue forKey:key];
}

- (IBAction)panGesture:(UIPanGestureRecognizer *)gesture {
    static UISlider *slider = nil;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        float x = [gesture locationInView:self.chartDrawingView].x;
        float width = self.chartDrawingView.frame.size.width;
        int barNumber = (int)(x*6/width);
        switch (barNumber) {
            case 0:
                slider = self.moodSlider;
                break;
            case 1:
                slider = self.stressSlider;
                break;
            case 2:
                slider = self.energySlider;
                break;
            case 3:
                slider = self.thoughtsSlider;
                break;
            case 4:
                slider = self.healthSlider;
                break;
            case 5:
                slider = self.sleepSlider;
                break;
            default:
                break;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        slider = nil;
    }
    else {
        float y = [gesture locationInView:self.chartDrawingView].y;
        float height = self.chartDrawingView.frame.size.height;
        float newChartValue = (int)((height - y)*20.0/height) - 10; // sliders range from -10 to 10
        [slider setValue:newChartValue];
        [self updateChart];
        [self setSliderColor:slider];
        [self setSliderData:slider];
    }
}

@end
