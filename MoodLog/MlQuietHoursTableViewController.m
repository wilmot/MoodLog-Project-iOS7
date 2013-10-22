//
//  MlQuietHoursTableViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 7/22/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
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
    dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");
    NSString *quietStartString = [NSString stringWithFormat:NSLocalizedString(@"Start time: %@", @"Start time: %@"),[dateFormatter stringFromDate: quietStart]];
    self.fromLabel.text = quietStartString;
}

- (void)setQuietEndLabel: (NSDate *) quietEnd {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");
    NSString *quietEndString = [NSString stringWithFormat:NSLocalizedString(@"End time: %@", @"End time: %@"),[dateFormatter stringFromDate: quietEnd]];
    self.toLabel.text = quietEndString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setTime:(id)sender {
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
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { // Start Time
        self.timePicker.date = self.detailItem.quietStart;
    }
    else if (indexPath.row == 1) { // End time
        self.timePicker.date = self.detailItem.quietEnd;
    }
}


@end
