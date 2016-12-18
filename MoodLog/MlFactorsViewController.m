//
//  MlFactorsViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 10/14/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
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
    else if ((deviceOrientation) == UIDeviceOrientationPortraitUpsideDown) {
        // do nothing
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
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Error saving Mood Log data", @"Core data saving error alert title")
                                     message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK button")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                   }];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


@end
