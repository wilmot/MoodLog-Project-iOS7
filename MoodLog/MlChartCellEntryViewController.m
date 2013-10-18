//
//  MlChartCellEntryViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/25/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlChartCellEntryViewController.h"
#import "MlChartCollectionViewController.h"

@interface MlChartCellEntryViewController ()

@end

@implementation MlChartCellEntryViewController

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
}

- (void)viewWillAppear:(BOOL)animated {
    self.infoTextView.text = self.detailItem.description;
    
    NSDate *today = [self.detailItem valueForKey:@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd YYYY h:mm a", @"Date format for Chart cells");
    self.dateLabel.text = [dateFormatter stringFromDate: today];

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
    [self setInfoTextView:nil];
    [self setDateLabel:nil];
    [super viewDidUnload];
}
@end
