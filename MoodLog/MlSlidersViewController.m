//
//  MlSlidersViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/12/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlSlidersViewController.h"

@interface MlSlidersViewController ()

@end

@implementation MlSlidersViewController

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
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
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

- (void) viewWillAppear:(BOOL)animated {
}

- (void) viewWillDisappear:(BOOL)animated {
    [self saveContext];
}

#pragma mark - Orientation change
- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        //landscape
        [self performSegueWithIdentifier:@"landscapeSliders" sender:self];
    }
    else {
        //portrait
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"landscapeSliders"]) {
        MlSlidersViewController *destinationViewController = [segue destinationViewController]; // Getting a reference to the collection view
        destinationViewController.detailItem = self.detailItem;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateChart {
    self.chartDrawingView.chartType = @"Bar";
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
    
    if (abs(sliderValue - previousValue) >= 1) {
        [self setSliderColor:sender];
        previousValue = sliderValue;
    }
    [(UISlider *)sender setValue:sliderValue]; // pin the slider to integral values
    [self updateChart];
}

- (void) setSliderColor:(id) sender {
    float sliderValue = [[NSNumber numberWithFloat:[(UISlider *)sender value]] floatValue];
    UIColor *sliderColor;
    if (sliderValue >= 0) { // Tint green
        sliderColor = [UIColor colorWithRed:fabsf((sliderValue  - 10.0)/20.0) green:(sliderValue + 10.0)/20.0 blue:1.0 - (sliderValue + 10.0)/20.0 alpha:1.0];
    }
    else { // Tint red
        sliderColor = [UIColor colorWithRed:fabsf((sliderValue - 10.0)/20.0) green:(sliderValue + 10.0)/20.0 blue:1.0 - fabsf((sliderValue - 10.0)/20.0) alpha:1.0];
    }
    [sender performSelector:@selector(setMinimumTrackTintColor:) withObject:sliderColor];
    [sender performSelector:@selector(setMaximumTrackTintColor:) withObject:sliderColor];
    //[sender setThumbTintColor:sliderColor];
    
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

- (void) saveContext { // Save data to the database
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // TODO: Remove the aborts()
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


@end
