//
//  MlChartCollectionViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/21/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlChartCollectionViewController.h"
#import "MlChartCollectionViewCell.h"
#import "MoodLogEvents.h"
#import "Emotions.h"
#import "Prefs.h"
#import "MlAppDelegate.h"

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
    
    unsigned numberOfLines, index, stringLength = [self.text length];
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([self.text lineRangeForRange:NSMakeRange(index, 0)]);

    int newLinesToAdd = labelLines - numberOfLines;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self setCellTypeAndSize:orientation];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChartCollectionView:nil];
    [self setManagedObjectContext:nil];
    [self setFetchedResultsController:nil];
    [super viewDidUnload];
}

- (void) setCellTypeAndSize: (UIInterfaceOrientation)toInterfaceOrientation {
    if (toInterfaceOrientation == UIDeviceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        // portrait
        NSUInteger frameheight = [[UIScreen mainScreen] bounds].size.height; // Different sizes for iPhone 4 vs. iPhone 5
        if ([self.chartType isEqualToString:@"Bar"]) {
            self.cellIdentifier = @"chartCellPortrait";
            cellSize = CGSizeMake(92.0,frameheight - 64);
            labelLines = frameheight/16;
        }
        else { // Pie
            self.cellIdentifier = @"pieChartCellPortrait";
            cellSize = CGSizeMake(92.0,frameheight - 64);
            labelLines = frameheight/16;
        }
    }
    else {
        // landscape
        if ([self.chartType isEqualToString:@"Bar"]) {
            self.cellIdentifier = @"chartCellPortrait";
            cellSize = CGSizeMake(92.0,256.0);
            labelLines = 16;
        }
        else { // Pie
            self.cellIdentifier = @"pieChartCellPortrait";
            cellSize = CGSizeMake(92.0,256.0);
            labelLines = 16;
        }
    }
    [self.chartCollectionView reloadData];
}

#pragma mark - Orientation change
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setCellTypeAndSize:toInterfaceOrientation];
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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"header" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)configureCell:(MlChartCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MoodLogEvents *moodLogObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDate *today = [moodLogObject valueForKey:@"date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];
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
        [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:oldToday];
        NSInteger oldDay = [oldWeekdayComponents day];
        if (oldDay != day) {
            dateFormatter.dateFormat = @"yyyy";
            cell.dateLabel.text = [dateFormatter stringFromDate: today];
            dateFormatter.dateFormat = @"MMMM dd";
            cell.monthLabel.text = [dateFormatter stringFromDate: today];
            dateFormatter.dateFormat = @"h:mm a";
            cell.timeLabel.text = [dateFormatter stringFromDate: today];
        }
        else {
            dateFormatter.dateFormat = @"yyyy";
            cell.dateLabel.text = @"";
            dateFormatter.dateFormat = @"MMMM dd";
            cell.monthLabel.text = @"";
            dateFormatter.dateFormat = @"h:mm a";
            cell.timeLabel.text = [dateFormatter stringFromDate: today];
        }
    }
    else {
        dateFormatter.dateFormat = @"yyyy";
        cell.dateLabel.text = [dateFormatter stringFromDate: today];
        dateFormatter.dateFormat = @"MMMM dd";
        cell.monthLabel.text = [dateFormatter stringFromDate: today];
        dateFormatter.dateFormat = @"h:mm a";
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
        
        key = @"Love";
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.loveLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.loveLabel.textColor = [[UIColor greenColor] darkerColor];
            cell.loveLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.loveLabel.font = [UIFont systemFontOfSize:15];
            cell.loveLabel.textColor = [[[UIColor greenColor] darkerColor] colorWithAlphaComponent:0.20];
            cell.loveLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
        key = @"Joy";
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.joyLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.joyLabel.textColor = [UIColor orangeColor];
            cell.joyLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.joyLabel.font = [UIFont systemFontOfSize:15];
            cell.joyLabel.textColor = [[[UIColor orangeColor] colorWithAlphaComponent:0.20] darkerColor];
            cell.joyLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
        key = @"Surprise";
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.surpriseLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.surpriseLabel.textColor = [UIColor purpleColor];
            cell.surpriseLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.surpriseLabel.font = [UIFont systemFontOfSize:15];
            cell.surpriseLabel.textColor = [[UIColor purpleColor] colorWithAlphaComponent:0.20];
            cell.surpriseLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
       key = @"Anger";
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.angerLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.angerLabel.textColor = [UIColor redColor];
            cell.angerLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.angerLabel.font = [UIFont systemFontOfSize:15];
            cell.angerLabel.textColor = [[UIColor redColor] colorWithAlphaComponent:0.20];
            cell.angerLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
        key = @"Sadness";
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.sadnessLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.sadnessLabel.textColor = [UIColor blueColor];
            cell.sadnessLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.sadnessLabel.font = [UIFont systemFontOfSize:15];
            cell.sadnessLabel.textColor = [[UIColor blueColor] colorWithAlphaComponent:0.20];
            cell.sadnessLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
        key = @"Fear";
        itemCount= (NSNumber *)[categoryCounts objectForKey:key];
        if ([itemCount integerValue] > 0) {
            cell.fearLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.fearLabel.textColor = [[UIColor yellowColor] darkerColor];
            cell.fearLabel.text = [NSString stringWithFormat:@"%@ %@\n", key, [categoryCounts objectForKey:key]];
        }
        else {
            cell.fearLabel.font = [UIFont systemFontOfSize:15];
            cell.fearLabel.textColor = [[[UIColor yellowColor] colorWithAlphaComponent:0.20] darkerColor];
            cell.fearLabel.text = [NSString stringWithFormat:@"%@    ", key];
        }
   }
    unsigned numberOfLines, index, stringLength = [displayString length];
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
        index = NSMaxRange([displayString lineRangeForRange:NSMakeRange(index, 0)]);

    cell.chartDrawingView.chartType = self.chartType;
    cell.chartDrawingView.categoryCounts = categoryCounts;
    if ([self.chartType isEqualToString:@"Bar"]) {
        CGFloat height = emotionArrayCount>0 ? feelTotal/emotionArrayCount : 0; // Average (mean)
        cell.chartHeightLabel.text = [NSString stringWithFormat:@"%2.0f", height];
        [cell.chartDrawingView setChartHeightOverall:[moodLogObject.overall floatValue]];
        [cell.chartDrawingView setChartHeightSleep:[moodLogObject.sleep floatValue]];
        [cell.chartDrawingView setChartHeightEnergy:[moodLogObject.energy floatValue]];
        [cell.chartDrawingView setChartHeightHealth:[moodLogObject.health floatValue]];

    }
    else { // Pie
        
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
