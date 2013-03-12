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
    [self.segment setTintColor:[UIColor colorWithRed:0.03 green:0.45 blue:0.08 alpha:1.0]];
    [self.toolBar setTintColor:[UIColor colorWithRed:0.03 green:0.45 blue:0.08 alpha:1.0]];

}

- (void)viewWillAppear:(BOOL)animated {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDoneButton:nil];
    [self setSegment:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}
- (IBAction)pressDone:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)chooseSegment:(id)sender {
    if (self.segment.selectedSegmentIndex == 0) { // Bar Chart
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
