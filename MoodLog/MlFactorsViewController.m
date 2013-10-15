//
//  MlFactorsViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/14/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlFactorsViewController.h"

@interface MlFactorsViewController ()

@end

@implementation MlFactorsViewController

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
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showPortraitOrLandscapeView];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self saveContext];
}

#pragma mark - Orientation change
- (void)orientationChanged:(NSNotification *)notification {
    [self showPortraitOrLandscapeView];
}

- (void) showPortraitOrLandscapeView {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    [self saveContext];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        //landscape
        self.portraitContainer.hidden = YES;
        self.landscapeContainer.hidden = NO;
        [self.landscapeController configureView];
    }
    else {
        //portrait
        self.portraitContainer.hidden = NO;
        self.landscapeContainer.hidden = YES;
        [self.portraitController configureView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sliders"]) {
        self.portraitController = [segue destinationViewController];
        self.portraitController.detailItem = self.detailItem;
    }
    else if ([segue.identifier isEqualToString:@"slidersLandscape"]) {
        self.landscapeController = [segue destinationViewController];
        self.landscapeController.detailItem = self.detailItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
