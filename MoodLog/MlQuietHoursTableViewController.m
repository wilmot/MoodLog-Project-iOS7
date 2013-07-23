//
//  MlQuietHoursTableViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/22/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlQuietHoursTableViewController.h"
#import "MlNotificationsTableViewController.h"

@interface MlQuietHoursTableViewController ()

@end

@implementation MlQuietHoursTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    [self setQuietStartLabel:self.detailItem.quietStart];
    [self.timePicker setDate:self.detailItem.quietStart];
    [self setQuietEndLabel:self.detailItem.quietEnd];
}

- (void)setQuietStartLabel: (NSDate *) quietStart {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"h:mm a";
    NSString *quietStartString = [NSString stringWithFormat:@"Start time: %@",[dateFormatter stringFromDate: quietStart]];
    self.fromLabel.text = quietStartString;
}

- (void)setQuietEndLabel: (NSDate *) quietEnd {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"h:mm a";
    NSString *quietEndString = [NSString stringWithFormat:@"End time: %@",[dateFormatter stringFromDate: quietEnd]];
    self.toLabel.text = quietEndString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setTime:(id)sender {
    NSLog(@"Timer set by: %@",sender);
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath.row == 0) { // Start Time
        self.detailItem.quietStart = self.timePicker.date;
        [self setQuietStartLabel:self.timePicker.date];
        [[NSUserDefaults standardUserDefaults] setObject:self.detailItem.quietStart forKey:@"DefaultRandomQuietStartTime"];
    }
    else if (indexPath.row == 1) { // End time
        self.detailItem.quietEnd = self.timePicker.date;
        [self setQuietEndLabel:self.timePicker.date];
        [[NSUserDefaults standardUserDefaults] setObject:self.detailItem.quietEnd forKey:@"DefaultRandomQuietEndTime"];
    }
    NSLog(@"Start and end dates: %@, %@",self.detailItem.quietStart, self.detailItem.quietEnd);
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected: %@",indexPath);
    if (indexPath.row == 0) { // Start Time
        self.timePicker.date = self.detailItem.quietStart;
    }
    else if (indexPath.row == 1) { // End time
        self.timePicker.date = self.detailItem.quietEnd;
    }
}


@end
