//
//  MlChartViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlChartViewController.h"

@interface MlChartViewController ()

@end

@implementation MlChartViewController

static short BAR_CHART = 1;

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
    self.myChartCollectionViewController.chartType = @"Bar"; // Default chart type
//    [self.segment setTintColor:[UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.0]];
//    [self.toolBar setTintColor:[UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:1.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.segment.selectedSegmentIndex = [defaults integerForKey:@"ChartSegmentState"];
    [self chooseSegment:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChartCollectionSegue"]) {
        self.myChartCollectionViewController = [segue destinationViewController]; // Getting a reference to the collection view
        self.myChartCollectionViewController.managedObjectContext = self.managedObjectContext;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

// Use these if I want to restrict the orientation -- playing with this
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
//}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeRight;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSegment:nil];
    [self setToolBar:nil];
    [[self myChartCollectionViewController] setManagedObjectContext:nil];
    [self setMyChartCollectionViewController:nil];
    [super viewDidUnload];
}
- (IBAction)pressDone:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:^(void){ NSLog(@"BL-L Test"); }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chooseSegment:(id)sender {
    if (self.segment.selectedSegmentIndex == BAR_CHART) { // Bar Chart
        self.myChartCollectionViewController.chartType = @"Bar";
    }
    else { // Pie Chart
        self.myChartCollectionViewController.chartType = @"Pie";        
    }
    UIInterfaceOrientation *orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self.myChartCollectionViewController setCellTypeAndSize:orientation];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.segment.selectedSegmentIndex forKey:@"ChartSegmentState"];
    [defaults synchronize];
}

@end
