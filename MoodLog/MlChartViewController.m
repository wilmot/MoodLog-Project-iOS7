//
//  MlChartViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 11/7/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlChartViewController.h"
#import "MlAppDelegate.h"
#import "Prefs.h"

@interface MlChartViewController ()

@end

@implementation MlChartViewController

static short SUMMARY_CHART = 0;
static short PIE_CHART = 1;
static short BAR_CHART = 2;
CGFloat TOOLS_HIDDEN_HEIGHT = 0; // Set in setToolsHeights
CGFloat TOOLS_SHOWN_HEIGHT  = 0; // Set in setToolsHeights

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeBroughtToForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeBroughtToForeground:) name:UIApplicationWillResignActiveNotification object:nil];
}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    [self.toolBar invalidateIntrinsicContentSize];
//}

- (void) didRotate:(NSNotification *)notification {
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (orientation == UIDeviceOrientationLandscapeLeft) {
//        NSLog(@"Landscape Left!");
//    }
//    else {
//        NSLog(@"Something else");
//    }
    [self setToolsHeights];

}

- (void)setToolsHeights {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    TOOLS_HIDDEN_HEIGHT = 50 + self.toolBar.frame.size.height; // Leave room for date buttons
    TOOLS_SHOWN_HEIGHT = 120 + self.toolBar.frame.size.height; // All controls show
    if ([defaults boolForKey:@"ToolsHidden"] || ([defaults objectForKey:@"ToolsHidden"] == nil)) {
        self.disclosureTriangle.image = [UIImage imageNamed:@"disclosure_closed_20.png"];
        self.toolsViewHeightConstraint.constant = TOOLS_HIDDEN_HEIGHT;
        self.eventCounterView.alpha = 0.0;
    }
    else {
        self.disclosureTriangle.image = [UIImage imageNamed:@"disclosure_open_20.png"];
        self.toolsViewHeightConstraint.constant = TOOLS_SHOWN_HEIGHT;
        self.eventCounterView.alpha = 1.0;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.managedObjectContext = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSUInteger events = [sectionInfo numberOfObjects];
    if (events > 0) {
        self.noRecordsView.hidden = YES;
    }
    else {
        self.noRecordsView.hidden = NO;
    }
    self.segment.selectedSegmentIndex = [defaults integerForKey:@"ChartSegmentState"];
    [self setToolsHeights];
    [self initializeRangeControl];

    [self chooseSegment:self];
    self.myChartCollectionViewController.chartFactorType = [defaults integerForKey:@"ChartFactorType"];
    [self setFactorButtonTitle: self];
}

- (void)viewDidAppear:(BOOL)animated {
    if ( (((MlAppDelegate *)[UIApplication sharedApplication].delegate).loggedIn == NO) && (((MlAppDelegate *)[UIApplication sharedApplication].delegate).showPrivacyScreen == YES) ) {
        [self performSegueWithIdentifier:@"showPrivacyScreen" sender:self];
    }
}

-(void) noticeBroughtToForeground:(NSNotification *)notification {
    [self viewDidAppear:YES];
}

- (void) initializeRangeControl {
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18) resizingMode:UIImageResizingModeStretch];
    // Set the background for any states you plan to use
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.allButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.allButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.monthButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.monthButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.weekButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.weekButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.todayButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.todayButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
        [self.latestButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.latestButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSUInteger events = [sectionInfo numberOfObjects];
    
    if (events > 0) {
        if (events == 1) {
            self.startSlider.hidden = YES;
            self.endSlider.hidden = YES;
        }
        else {
            self.startSlider.hidden = NO;
            self.endSlider.hidden = NO;
        }
        UIImage *clearImage = [[UIImage alloc] init];
        [self.startSlider setMinimumValue:0];
        [self.startSlider setMaximumValue:events - 1];
        [self.startSlider setThumbImage:[UIImage imageNamed:@"slider_thumb_down_20.png"] forState:UIControlStateNormal];
        [self.startSlider setThumbImage:[UIImage imageNamed:@"slider_thumb_down_blue_20.png"] forState:UIControlStateHighlighted];
        [self.startSlider setMinimumTrackImage:clearImage forState:UIControlStateNormal];
        [self.startSlider setMaximumTrackImage:clearImage forState:UIControlStateNormal];
        [self.endSlider setMinimumValue:0];
        [self.endSlider setMaximumValue:events - 1];
        [self.endSlider setThumbImage:[UIImage imageNamed:@"slider_thumb_up_20.png"] forState:UIControlStateNormal];
        [self.endSlider setThumbImage:[UIImage imageNamed:@"slider_thumb_up_blue_20.png"] forState:UIControlStateHighlighted];
        [self.endSlider setMinimumTrackImage:clearImage forState:UIControlStateNormal];
        [self.endSlider setMaximumTrackImage:clearImage forState:UIControlStateNormal];
        for (id item in self.itemsToDisableTogether) {
            ((UIControl *)item).enabled = YES;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSDate *today = [object valueForKey:@"date"];
        
        indexPath = [NSIndexPath indexPathForItem:events - 1 inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        today = [object valueForKey:@"date"];
        
        // Position the sliders and highlight the buttons
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ( [defaults objectForKey:@"DefaultChartStartValue"] == nil ) {
            self.startSlider.value = self.startSlider.maximumValue;
            self.endSlider.value = self.startSlider.maximumValue;
            [self pressAllButton:self];
        }
        else {
            self.startSlider.value = [defaults floatForKey:@"DefaultChartStartValue"];
            self.endSlider.value = [defaults floatForKey:@"DefaultChartEndValue"];
        }
        
        if ([defaults boolForKey:@"ChartSliderPinnedToNewest"] == YES) {
            self.endSlider.value = self.endSlider.maximumValue;
        }
        if ([defaults boolForKey:@"ChartLatestButtonOn"]) {
            self.latestButton.selected = YES;
            [self pressLatestButton:self];
        }
        else if ([defaults boolForKey:@"ChartTodayButtonOn"]) {
            if ([self recordsForToday]) {
                self.todayButton.selected = YES;
                [self pressTodayButton:self];
            }
            else { // Select the newest if there are no records for today.
                self.latestButton.selected = YES;
                [self pressLatestButton:self];
            }
        }
        else if ([defaults boolForKey:@"Chart7DayButtonOn"]) {
            self.weekButton.selected = YES;
            [self pressWeekButton:self];
        }
        else if ([defaults boolForKey:@"Chart28DayButtonOn"]) {
            self.monthButton.selected = YES;
            [self pressMonthButton:self];
        }
        else if ([defaults boolForKey:@"ChartAllButtonOn"]) {
            self.allButton.selected = YES;
            [self pressAllButton:self];
        }
        if (![self recordsForToday]) {
            self.todayButton.enabled = NO;
            self.todayButton.selected = NO;
        }
        [self updateDateRangeDrawing];
    }
    else {
        self.startSlider.hidden = YES;
        self.endSlider.hidden = YES;
        [self.startSlider setMinimumValue:0];
        [self.startSlider setMaximumValue:0];
        [self.endSlider setMinimumValue:0];
        [self.endSlider setMaximumValue:0];
        for (id item in self.itemsToDisableTogether) {
            ((UIControl *)item).enabled = NO;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChartCollectionSegue"]) {
        self.myChartCollectionViewController = [segue destinationViewController]; // Getting a reference to the collection view
    }
    else if ([segue.identifier isEqualToString:@"SummarySegue"]) {
        self.mySummaryInfoViewController = [segue destinationViewController]; // Getting a reference to the Summary view
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [self setSegment:nil];
    [self setToolBar:nil];
    [[self myChartCollectionViewController] setManagedObjectContext:nil];
    [self setMyChartCollectionViewController:nil];
    // ChartControl controls
    [self setStartSlider:nil];
    [self setEndSlider:nil];
    [self setAllButton:nil];
    [self setMonthButton:nil];
    [self setWeekButton:nil];
    [self setTodayButton:nil];
    [self setLatestButton:nil];
    [self setDateRangeDrawing:nil];
    [self setEventCount:nil];
    [self setDateRangeLabel:nil];
    [super didReceiveMemoryWarning];
}

- (void)setFactorButtonTitle: (id) sender {
    if (self.segment.selectedSegmentIndex == BAR_CHART) {
        self.barFactorButton.enabled = YES;
        switch (self.myChartCollectionViewController.chartFactorType) {
            case AllType:
                self.barFactorButton.title = @"All";
                break;
            case MoodType:
                self.barFactorButton.title = @"Mood";
                break;
            case StressType:
                self.barFactorButton.title = @"Stress";
                break;
            case EnergyType:
                self.barFactorButton.title = @"Energy";
                break;
            case ThoughtsType:
                self.barFactorButton.title = @"Mind";
                break;
            case HealthType:
                self.barFactorButton.title = @"Health";
                break;
            case SleepType:
                self.barFactorButton.title = @"Sleep";
                break;
            default:
                self.barFactorButton.title = @"All";
                break;
        }
    }
    else {
        self.barFactorButton.enabled = NO;
        self.barFactorButton.title = @"";
    }
}

- (IBAction)chooseFactorType:(id)sender {
    switch (self.myChartCollectionViewController.chartFactorType) {
        case AllType:
            self.myChartCollectionViewController.chartFactorType = MoodType;
            break;
        case MoodType:
            self.myChartCollectionViewController.chartFactorType = StressType;
            break;
        case StressType:
            self.myChartCollectionViewController.chartFactorType = EnergyType;
            break;
        case EnergyType:
            self.myChartCollectionViewController.chartFactorType = ThoughtsType;
            break;
        case ThoughtsType:
            self.myChartCollectionViewController.chartFactorType = HealthType;
            break;
        case HealthType:
            self.myChartCollectionViewController.chartFactorType = SleepType;
            break;
        case SleepType:
            self.myChartCollectionViewController.chartFactorType = AllType;
            break;
        default:
            self.myChartCollectionViewController.chartFactorType = AllType;
            break;
    }
    [self setFactorButtonTitle: self];
    [self.myChartCollectionViewController.collectionView reloadData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.myChartCollectionViewController.chartFactorType forKey:@"ChartFactorType"];
    [defaults synchronize];
}

- (IBAction)pressDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chooseSegment:(id)sender {
    if(self.segment.selectedSegmentIndex == SUMMARY_CHART) { // Summary
        self.summaryView.hidden = NO;
        self.mySummaryInfoViewController.showSummary = YES;
        [self.mySummaryInfoViewController summaryInformationQuick:self];
        [self.mySummaryInfoViewController performSelector:@selector(summaryInformationSlow:) withObject:self afterDelay:0.2 ];
        self.chartContainer.hidden = YES;
    }
    else if (self.segment.selectedSegmentIndex == BAR_CHART) { // Bar Chart
        self.summaryView.hidden = YES;
        self.mySummaryInfoViewController.showSummary = NO;
        self.chartContainer.hidden = NO;
        self.myChartCollectionViewController.chartType = @"Bar";
    }
    else if (self.segment.selectedSegmentIndex == PIE_CHART) {
        self.summaryView.hidden = YES;
        self.mySummaryInfoViewController.showSummary = NO;
        self.chartContainer.hidden = NO;
        self.myChartCollectionViewController.chartType = @"Pie";
    }
    else {
        // there is no fourth option
    }
    [self setFactorButtonTitle:self];
    [self.myChartCollectionViewController setCellType:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.segment.selectedSegmentIndex forKey:@"ChartSegmentState"];
    [defaults synchronize];
}

- (IBAction)toggleControls:(id)sender {
    CGFloat newValue = 0;
    CGFloat newAlpha = 1.0;
    BOOL newHidden = NO;
    UIImage *image;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.toolsViewHeightConstraint.constant > TOOLS_HIDDEN_HEIGHT) {
        newValue = TOOLS_HIDDEN_HEIGHT;
        newHidden = YES;
        newAlpha = 0.0;
        image = [UIImage imageNamed:@"disclosure_closed_20.png"];
        [defaults setBool:YES forKey:@"ToolsHidden"];
    }
    else {
        newValue = TOOLS_SHOWN_HEIGHT;
        newHidden = NO;
        newAlpha = 1.0;
        image = [UIImage imageNamed:@"disclosure_open_20.png"];
        [defaults setBool:NO forKey:@"ToolsHidden"];
    }
    [defaults synchronize];
    self.disclosureTriangle.image = image;
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^ {
                         self.toolsViewHeightConstraint.constant = newValue;
                         self.eventCounterView.alpha = newAlpha;
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL finished) {
                     }];
    [self.myChartCollectionViewController.chartCollectionView reloadData];
    [self.myChartCollectionViewController.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - RangeControl Methods

- (IBAction)pressAllButton:(id)sender {
    self.startSlider.value = 0.0;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
    [self.mySummaryInfoViewController summaryInformationSlow: self];
    [self saveSliderState];
    [self setButtonHighlighting:self.allButton];
}

- (IBAction)pressMonthButton:(id)sender {
    NSIndexPath *indexPath;
    MoodLogEvents *object;
    NSDate *today = [NSDate date];
    today = [today dateByAddingTimeInterval: -60*60*24*28]; // Subtract a month (28 days) from today
    int monthOldEntry=0;
    NSDate *aDay;
    for (int i=[self.endSlider maximumValue]; i>=0; i--) {
        indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aDay = [object valueForKey:@"date"];
        if ([aDay timeIntervalSince1970] <= [today timeIntervalSince1970]) {
            monthOldEntry = MIN(i+1,[self.endSlider maximumValue]);
            break;
        }
    }
    self.startSlider.value = monthOldEntry;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
    [self.mySummaryInfoViewController summaryInformationSlow: self];
    [self saveSliderState];
    [self setButtonHighlighting:self.monthButton];
}

- (IBAction)pressWeekButton:(id)sender {
    // Iterate backwards through the records until you get to the first one that's within a week old
    NSIndexPath *indexPath;
    MoodLogEvents *object;
    NSDate *today = [NSDate date];
    today = [today dateByAddingTimeInterval: -60*60*24*7]; // Subtract a week from today
    int weekOldEntry=0;
    NSDate *aDay = [[NSDate alloc] init];
    for (int i=[self.endSlider maximumValue]; i>=0; i--) {
        indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aDay = [object valueForKey:@"date"];
        if ([aDay timeIntervalSince1970] < [today timeIntervalSince1970]) {
            weekOldEntry = MIN(i+1,[self.endSlider maximumValue]);
            break;
        }
    }
    self.startSlider.value = weekOldEntry;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
    [self.mySummaryInfoViewController summaryInformationSlow: self];
    [self saveSliderState];
    [self setButtonHighlighting:self.weekButton];
}

- (IBAction)pressTodayButton:(id)sender {
    // Iterate backwards through the records until you get to the first one that's earlier than today
    NSIndexPath *indexPath;
    MoodLogEvents *object;
    NSDate *today = [NSDate date];
    today = [NSCalendar.currentCalendar startOfDayForDate:today];
    int dayOldEntry=0;
    NSDate *aDay = [[NSDate alloc] init];
    for (int i=[self.endSlider maximumValue]; i>=0; i--) {
        indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aDay = [object valueForKey:@"date"];
        if ([aDay timeIntervalSince1970] <= [today timeIntervalSince1970]) {
            dayOldEntry = MIN(i+1,[self.endSlider maximumValue]);
            break;
        }
    }
    self.startSlider.value = dayOldEntry;
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
    [self.mySummaryInfoViewController summaryInformationSlow: self];
    [self saveSliderState];
    [self setButtonHighlighting:self.todayButton];
}

- (IBAction)pressLatestButton:(id)sender {
    self.startSlider.value = [self.startSlider maximumValue];
    self.endSlider.value = [self.endSlider maximumValue];
    [self updateDateRangeDrawing];
    [self.mySummaryInfoViewController summaryInformationSlow: self];
    [self saveSliderState];
    [self setButtonHighlighting:self.latestButton];
}

- (BOOL)recordsForToday {
    // Iterate backwards through the records until you get to the first one that's earlier than today
    NSIndexPath *indexPath;
    MoodLogEvents *object;
    NSDate *aDayAgo = [NSDate date];
    aDayAgo = [aDayAgo dateByAddingTimeInterval: -60*60*24]; // Subtract one day from today
    NSDate *aDay = [[NSDate alloc] init];
    for (int i=self.endSlider.maximumValue; i>=0; i--) {
        indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        aDay = [object valueForKey:@"date"];
        if ([aDay timeIntervalSince1970] >= [aDayAgo timeIntervalSince1970]) {
            return YES;
            break;
        }
    }
    return NO;
}

- (void) updateDateRangeDrawing {
    int startValue = (int)roundl(self.startSlider.value);
    int endValue = (int)roundl(self.endSlider.value);
    int events = (endValue - startValue) + 1;
    if (startValue > -1) {
        NSString *text;
        switch (events) {
            case 0:
                text = NSLocalizedString(@"No entries", @"No entries - range picker");
                break;
            case 1:
                text = NSLocalizedString(@"entry", @"entry - range picker");
                break;
            default:
                text = NSLocalizedString(@"entries", @"entries - range picker");
                break;
        }
        self.eventCount.text = [NSString stringWithFormat:@"%d %@",events, text];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:startValue inSection:0];
        MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSDate *today = [object valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd, YYYY", @"MMMM dd, YYYY date format");
        NSString *startDate = [dateFormatter stringFromDate: today];
        self.startDate = today;
        self.myChartCollectionViewController.startDate = today;
        self.mySummaryInfoViewController.startDate = today;

        indexPath = [NSIndexPath indexPathForItem:endValue inSection:0];
        object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        today = [object valueForKey:@"date"];
        NSString *endDate = [dateFormatter stringFromDate:today];
        self.endDate = today;
        self.myChartCollectionViewController.endDate = today;
        self.mySummaryInfoViewController.endDate = today;
        
        if ([startDate isEqualToString:endDate]) {
            self.dateRangeLabel.text = [NSString stringWithFormat:@"%@", startDate];
        }
        else {
            self.dateRangeLabel.text = [NSString stringWithFormat:@"%@ to %@", startDate, endDate];
        }
        
        if (self.startSlider.maximumValue > 0) {
            self.dateRangeDrawing.startValue = [NSNumber numberWithFloat:self.startSlider.value/self.startSlider.maximumValue];
            self.dateRangeDrawing.endValue = [NSNumber numberWithFloat:self.endSlider.value/self.endSlider.maximumValue];
        } else {
            self.dateRangeDrawing.startValue = [NSNumber numberWithFloat:self.startSlider.value/1.0];
            self.dateRangeDrawing.endValue = [NSNumber numberWithFloat:self.endSlider.value/1.0];
        }
        [self.dateRangeDrawing setNeedsDisplay];
        self.myChartCollectionViewController.fetchedResultsController = nil; // Force it to search again
        self.mySummaryInfoViewController.fetchedResultsControllerByDate = nil;
        self.mySummaryInfoViewController.fetchedResultsControllerByEmotion = nil;
        self.mySummaryInfoViewController.fetchedResultsControllerByCategory = nil;
        [self.myChartCollectionViewController.collectionView reloadData];
        self.mySummaryInfoViewController.showSummary = YES;
        [self.mySummaryInfoViewController summaryInformationQuick:self];
        // [self.mySummaryInfoViewController summaryInformationSlow: self];
        [self scrollToEnd];
    }
}

- (void) scrollToEnd {
    NSInteger section = [self.myChartCollectionViewController.collectionView numberOfSections] - 1;
    NSInteger item = [self.myChartCollectionViewController.collectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    [self.myChartCollectionViewController.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}

- (void) setButtonHighlighting: (UIButton *)button {
    // Clear all the buttons
    [self.latestButton setSelected:NO];
    [self.todayButton setSelected:NO];
    [self.weekButton setSelected:NO];
    [self.monthButton setSelected:NO];
    [self.allButton setSelected:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"ChartLatestButtonOn"];
    [defaults setBool:NO forKey:@"ChartTodayButtonOn"];
    [defaults setBool:NO forKey:@"Chart7DayButtonOn"];
    [defaults setBool:NO forKey:@"Chart28DayButtonOn"];
    [defaults setBool:NO forKey:@"ChartAllButtonOn"];
    // Set the one you want
    if (button != Nil) {
        // Determine which button was pressed so I can set the state and the defaults
        if (button == self.latestButton) {
            [defaults setBool:YES forKey:@"ChartLatestButtonOn"];
            [self.latestButton setSelected:YES];
        }
        else if (button == self.todayButton) {
            [defaults setBool:YES forKey:@"ChartTodayButtonOn"];
            [self.todayButton setSelected:YES];
        }
        else if (button == self.weekButton) {
            [defaults setBool:YES forKey:@"Chart7DayButtonOn"];
            [self.weekButton setSelected:YES];
        }
        else if (button == self.monthButton) {
            [defaults setBool:YES forKey:@"Chart28DayButtonOn"];
            [self.monthButton setSelected:YES];
        }
        else if (button == self.allButton) {
            [defaults setBool:YES forKey:@"ChartAllButtonOn"];
            [self.allButton setSelected:YES];
        }
    }
    [defaults synchronize];
}

- (IBAction)slideStartSlider:(id)sender {
    if (self.startSlider.value > self.endSlider.value) {
        [self.endSlider setValue:[self.startSlider value]];
    }
    [self updateDateRangeDrawing];
    [self setButtonHighlighting:nil];
}

- (IBAction)slideEndSlider:(id)sender {
    if (self.endSlider.value < self.startSlider.value) {
        [self.startSlider setValue:[self.endSlider value]];
    }
    [self updateDateRangeDrawing];
    [self setButtonHighlighting:nil];
}

- (IBAction)finishedSlidingStartSlider:(id)sender {
    int discreteEndValue = roundl([self.startSlider value]);
    [self.startSlider setValue:(float)discreteEndValue];
    if (self.startSlider.value > self.endSlider.value) {
        [self.endSlider setValue:(float)discreteEndValue];
    }
    [self updateDateRangeDrawing];
    [self.mySummaryInfoViewController summaryInformationSlow: self];
    [self saveSliderState];
}

- (IBAction)finishedSlidingEndSlider:(id)sender {
    int discreteEndValue = roundl([self.endSlider value]);
    [self.endSlider setValue:(float)discreteEndValue];
    if (self.endSlider.value < self.startSlider.value) {
        [self.startSlider setValue:(float)discreteEndValue];
    }
    [self updateDateRangeDrawing];
    [self.mySummaryInfoViewController summaryInformationSlow: self];
    [self saveSliderState];
}

- (void) saveSliderState {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.startSlider.value forKey:@"DefaultChartStartValue"];
    [defaults setFloat:self.endSlider.value forKey:@"DefaultChartEndValue"];
    if (self.endSlider.value == self.endSlider.maximumValue) {
        [defaults setBool:YES forKey:@"ChartSliderPinnedToNewest"];
    }
    else {
        [defaults setBool:NO forKey:@"ChartSliderPinnedToNewest"];
    }
    [defaults synchronize];
}

#pragma mark - Core Data delegate methods

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MoodLogEvents" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    if ((self.startDate != nil) && (self.endDate != nil)) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date >= %@ && date <= %@", self.startDate, self.endDate];
    }

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]; //mainCacheName
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Error retrieving Mood-Log data", @"Core data retrieving error alert title")
                                     message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data unknown error alert text"), error, [error userInfo]]
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
    
    return _fetchedResultsController;
}

@end
