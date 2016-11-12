//
//  MlChartCollectionViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/21/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import "MlChartCollectionViewController.h"
#import "MlChartCollectionViewCell.h"
#import "MoodLogEvents.h"
#import "Emotions.h"
#import "Prefs.h"
#import "MlAppDelegate.h"
#import "MlColorChoices.h"

CGSize cellSize;
NSUInteger labelLines;
NSUInteger bottomLabelHeight = 50.0; // Height of view at bottom of CollectionViewCells (date labels are there)
Boolean firstLoad;

// Category for UILabel to align text to the bottom by adding newlines
@interface UILabel (AlignBottom)
- (void)addLines;
@end

@implementation UILabel (AlignBottom)

- (void)addLines {
    [self setNumberOfLines:labelLines];
    
    NSUInteger numberOfLines, index, stringLength = [self.text length];
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([self.text lineRangeForRange:NSMakeRange(index, 0)]);

    NSUInteger newLinesToAdd = (int)abs((int)labelLines - (int)numberOfLines - 1); // abs is just a stab in the dark
    for(int i=0; i<newLinesToAdd; i++)
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
}
@end


@interface MlChartCollectionViewController ()

@end

@implementation MlChartCollectionViewController

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
    if (!self.cellIdentifier) {
        self.cellIdentifier = @"chartCellPortrait";
    }
    self.managedObjectContext = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    firstLoad = YES;

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // On first load, go to the end of the CollectionView (most recent)
    if (firstLoad) {
        if ([[self.fetchedResultsController sections] count]) { // If there are any records
            NSUInteger lastSection = [[self.fetchedResultsController sections] count] - 1;
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.chartCollectionView numberOfItemsInSection:lastSection] - 1) inSection:lastSection];
            [self.chartCollectionView scrollToItemAtIndexPath:scrollIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        }
        firstLoad = NO;
    }
    [self.chartCollectionView.collectionViewLayout invalidateLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [self setChartCollectionView:nil];
    [self setManagedObjectContext:nil];
    [self setFetchedResultsController:nil];
    [super viewDidUnload];
}

- (void) setCellType: (id)sender {
        if ([self.chartType isEqualToString:@"Bar"]) {
            self.cellIdentifier = @"chartCellPortrait";
        }
        else { // Pie
            self.cellIdentifier = @"pieChartCellPortrait";
        }
    [self.chartCollectionView reloadData];
}


#pragma mark - Orientation change
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.chartCollectionView.collectionViewLayout invalidateLayout];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self.chartCollectionView reloadData];
}

#pragma mark - Delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger collectionViewHeight = self.chartCollectionView.bounds.size.height;
    cellSize = CGSizeMake(92.0,collectionViewHeight);
    labelLines = 16/collectionViewHeight;

    return cellSize; // set when orientation changes
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    MlChartCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

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
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"header" cacheName:nil]; //mainCacheName
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"An unknown error has occurred:  %@, %@", error, [error userInfo]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to student@voyageropen.org", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
	}
    
    return _fetchedResultsController;
}

- (void)configureCell:(MlChartCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MoodLogEvents *moodLogObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDate *today = [moodLogObject valueForKey:@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
    NSInteger day = [weekdayComponents day];
    
    static NSArray *dayNames = nil;
    if (!dayNames) {
        [dateFormatter setCalendar:[NSCalendar currentCalendar]];
        dayNames = [dateFormatter weekdaySymbols];
    }
    
    // TODO: This logic is convoluted; revisit
    if ([indexPath row] > 0) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:[indexPath row] - 1 inSection:[indexPath section]];
        MoodLogEvents *previousObject = [self.fetchedResultsController objectAtIndexPath:oldIndexPath];
        NSDate *oldToday = [previousObject valueForKey:@"date"];
        NSDateComponents *oldWeekdayComponents =
        [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:oldToday];
        NSInteger oldDay = [oldWeekdayComponents day];
        if (oldDay != day) {
            dateFormatter.dateFormat = NSLocalizedString(@"yyyy", @"Year date format");
            cell.dateLabel.text = [dateFormatter stringFromDate: today];
            dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd", @"Month day date format");
            cell.monthLabel.text = [dateFormatter stringFromDate: today];
            dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");
            cell.timeLabel.text = [dateFormatter stringFromDate: today];
        }
        else {
            dateFormatter.dateFormat = NSLocalizedString(@"yyyy", @"Year date format");
            cell.dateLabel.text = @"";
            dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd", @"Month day date format");
            cell.monthLabel.text = @"";
            dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");
            cell.timeLabel.text = [dateFormatter stringFromDate: today];
        }
    }
    else {
        dateFormatter.dateFormat = NSLocalizedString(@"yyyy", @"Year date format");
        cell.dateLabel.text = [dateFormatter stringFromDate: today];
        dateFormatter.dateFormat = NSLocalizedString(@"MMMM dd", @"Month day date format");
        cell.monthLabel.text = [dateFormatter stringFromDate: today];
        dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");
        cell.timeLabel.text = [dateFormatter stringFromDate: today];
    }

    cell.detailItem = moodLogObject;
    cell.myViewController = self;
    
    // Fetch the Mood list for this journal entry
    NSSet *emotionsforEntry = moodLogObject.relationshipEmotions; // Get all the emotions for this record
    NSPredicate *myFilter = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]];
    NSArray *emotionArray = [[[emotionsforEntry filteredSetUsingPredicate:myFilter] allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSString *selectedEms = [[NSString alloc] init];
    NSUInteger emotionArrayCount = [emotionArray count];
    CGFloat feelTotal = 0;
    
    NSMutableDictionary *categoryCounts = [@{love : @0, joy : @0, surprise : @0, fear : @0, anger : @0, sadness : @0} mutableCopy];
    if (emotionArrayCount > 0) {
        for (Emotions *emotion in emotionArray) {
            // selectedEms = [selectedEms stringByAppendingFormat:@"%@ (%@)\n", [((Emotions *)emotion).name lowercaseString], ((Emotions *)emotion).feelValue];
            selectedEms = [selectedEms stringByAppendingFormat:@"%@\n", [emotion.name lowercaseString]];
            feelTotal += emotion.feelValue.floatValue;
            NSString *thisCategory = emotion.category;
            if (categoryCounts[thisCategory]) {
                categoryCounts[thisCategory] = @([categoryCounts[thisCategory] integerValue] + [@1 integerValue]); // increment
            }
        }
    }
    NSString *displayString = [[NSString alloc] init];
    if ([self.chartType isEqualToString:@"Bar"]) {
        if (emotionArray) {
            displayString = [displayString stringByAppendingFormat:@"%@", selectedEms];
            cell.emotionsLabel.text = displayString;
            [cell.emotionsLabel addLines];
       }
    }
    else { // Pie
        NSString *key;
        NSNumber *itemCount;
        NSDictionary *colorz = [MlColorChoices textColors];
        
        key = love;
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.loveLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.loveLabel.textColor = [colorz objectForKey:love];
            cell.loveLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.loveLabel.font = [UIFont systemFontOfSize:15];
            cell.loveLabel.textColor = [[colorz objectForKey:love] colorWithAlphaComponent:0.20];
            cell.loveLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
        key = joy;
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.joyLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.joyLabel.textColor = [colorz objectForKey:joy];
            cell.joyLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.joyLabel.font = [UIFont systemFontOfSize:15];
            cell.joyLabel.textColor = [[[colorz objectForKey:joy] colorWithAlphaComponent:0.20] darkerColor];
            cell.joyLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
        key = surprise;
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.surpriseLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.surpriseLabel.textColor = [colorz objectForKey:surprise];
            cell.surpriseLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.surpriseLabel.font = [UIFont systemFontOfSize:15];
            cell.surpriseLabel.textColor = [[colorz objectForKey:surprise] colorWithAlphaComponent:0.20];
            cell.surpriseLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
       key = anger;
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.angerLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.angerLabel.textColor = [colorz objectForKey:anger];
            cell.angerLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.angerLabel.font = [UIFont systemFontOfSize:15];
            cell.angerLabel.textColor = [[colorz objectForKey:anger] colorWithAlphaComponent:0.20];
            cell.angerLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
        key = sadness;
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.sadnessLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.sadnessLabel.textColor = [colorz objectForKey:sadness];
            cell.sadnessLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.sadnessLabel.font = [UIFont systemFontOfSize:15];
            cell.sadnessLabel.textColor = [[colorz objectForKey:sadness] colorWithAlphaComponent:0.20];
            cell.sadnessLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
        key = fear;
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.fearLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.fearLabel.textColor = [colorz objectForKey:fear];
            cell.fearLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.fearLabel.font = [UIFont systemFontOfSize:15];
            cell.fearLabel.textColor = [[[colorz objectForKey:fear] colorWithAlphaComponent:0.20] darkerColor];
            cell.fearLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
   }
    NSUInteger numberOfLines, index, stringLength = [displayString length];
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([displayString lineRangeForRange:NSMakeRange(index, 0)]);

    cell.chartDrawingView.chartType = self.chartType;
    cell.chartDrawingView.categoryCounts = categoryCounts;
    cell.chartDrawingView.dividerLine = YES;
    if ([self.chartType isEqualToString:@"Bar"]) {
        CGFloat height = emotionArrayCount>0 ? feelTotal/emotionArrayCount : 0; // Average (mean)
        cell.chartHeightLabel.text = [NSString stringWithFormat:@"%2.0f", height];
        [cell.chartDrawingView setChartHeightOverall:[moodLogObject.overall floatValue]];
        [cell.chartDrawingView setChartHeightStress:[moodLogObject.stress floatValue]];
        [cell.chartDrawingView setChartHeightEnergy:[moodLogObject.energy floatValue]];
        [cell.chartDrawingView setChartHeightThoughts:[moodLogObject.thoughts floatValue]];
        [cell.chartDrawingView setChartHeightHealth:[moodLogObject.health floatValue]];
        [cell.chartDrawingView setChartHeightSleep:[moodLogObject.sleep floatValue]];
    }
    else { // Pie
        
    }
    BOOL debugging = [  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Debugging"] integerValue];
    if (debugging) {
        cell.detailButton.enabled = YES;
    }
    else {
        cell.detailButton.enabled = NO;
    }
    [cell.chartDrawingView setNeedsDisplay]; // without this, the bars don't match the data
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chartCellDetail"]) {
        self.myChartCellEntryViewController = [segue destinationViewController]; // Getting a reference to the collection view
        self.myChartCellEntryViewController.detailItem = self.detailItem;
    }
}


@end
