//
//  MlWelcomeScreenViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/18/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlWelcomeScreenViewController.h"
#import "MlAppDelegate.h"

@interface MlWelcomeScreenViewController ()

@end

@implementation MlWelcomeScreenViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeBroughtToForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeBroughtToForeground:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if ( (((MlAppDelegate *)[UIApplication sharedApplication].delegate).loggedIn == NO) && (((MlAppDelegate *)[UIApplication sharedApplication].delegate).showPrivacyScreen == YES) ) {
        [self performSegueWithIdentifier:@"showPrivacyScreen" sender:self];
    }
}

- (void)viewDidLayoutSubviews {
    if (self.textView != nil) {
    [self.textView setContentOffset:CGPointZero animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressDoneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) noticeBroughtToForeground:(NSNotification *)notification {
    [self viewDidAppear:YES];
}

@end
