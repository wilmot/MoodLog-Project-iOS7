//
//  MlMasterViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlMasterViewController.h"
#import "MlDetailViewController.h"
#import "MlMoodDataItem.h"
#import "MlAppDelegate.h"
#import "Emotions.h"
#import "MlCell.h"
#import "MlMailViewController.h"
#import "Prefs.h"

@interface MlMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MlMasterViewController

static CGFloat CELL_HEIGHT;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New", @"New button") style:UIBarButtonItemStylePlain target:self action:@selector(insertNewObject:)];
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (MlDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    //[self updateOldRecords];
    //[self deleteUnselectedEmotionsFromOldRecords];
    //[self deleteEmotionsWithNullParent];
    
    CELL_HEIGHT = [[self.tableView dequeueReusableCellWithIdentifier:@"Cell"] bounds].size.height;

}

- (void) updateOldRecords {
    NSArray *emotionsFromPList = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).emotionsFromPList;
    NSDateComponents *components;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSLog(@"Running the updateOldRecords method. Turn this off after you've run it on your data.");
    int i = 0;
    for (MoodLogEvents *object in [[self fetchedResultsController] fetchedObjects]) {
        NSSet *emotions = object.relationshipEmotions;
        for(Emotions *emotion in emotions) {
            for (MlMoodDataItem *mood in emotionsFromPList) {
                if ([emotion.name isEqualToString:mood.mood]) {
                    emotion.category = mood.category;
                    emotion.parrotLevel = [NSNumber numberWithInt:[mood.parrotLevel integerValue]];
                    emotion.feelValue = [NSNumber numberWithInt:[mood.feelValue integerValue]];
                    emotion.facePath = mood.facePath;
                }
            }
            
        }
        // Make sure the header reflects the current date
        components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:object.date];
        object.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
        if (i++%10 == 0) {
            NSLog(@"Saving records...");
            [self saveContext];
        }
    }
    [self saveContext];
    NSLog(@"Updated all records.");
}

- (void) deleteUnselectedEmotionsFromOldRecords {
    NSArray *emotionsFromPList = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).emotionsFromPList;
    NSLog(@"Running the deleteUnselectedEmotionsFromOldRecords method. Turn this off after you've run it on your data.");
    int i = 0;
    for (MoodLogEvents *object in [[self fetchedResultsController] fetchedObjects]) {
        NSSet *originalEmotions = object.relationshipEmotions;
        NSMutableSet *newEmotions = [[NSMutableSet alloc] init];
        for(Emotions *emotion in originalEmotions) {
            for (MlMoodDataItem *mood in emotionsFromPList) {
                if ([emotion.name isEqualToString:[mood valueForKey:@"mood"]]) {
                    if ([emotion.selected boolValue]) {
                        [newEmotions addObject:emotion];
                    }
                }
            }
        }
        [object removeRelationshipEmotions:originalEmotions]; // Clear out the big set
        [object addRelationshipEmotions:newEmotions]; // Install the little set
        if (i++%10 == 0) {
            NSLog(@"Saving records...");
            [self saveContext];
        }
    }
    [self saveContext];
    NSLog(@"Removed unselected emotions from all records.");
}

- (void) deleteEmotionsWithNullParent {
    MlAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    int i = 0;
    NSArray *allTheEmotions = [[self fetchedResultsControllerForEmotions] fetchedObjects];
    NSLog(@"Running the deleteEmotionsWithNullParent method. Processing %d records", [allTheEmotions count]);
    for (Emotions *anEmotion in allTheEmotions) {
        if (anEmotion.logParent == NULL) {
          //  NSLog(@"About to delete %@, because logParent = %@",anEmotion,anEmotion.logParent);
          [[delegate managedObjectContext] deleteObject:anEmotion];

        }
        else {
            NSLog(@"Found a fine emotion to keep: %@",anEmotion);
        }
        if (i++%20 == 0) {
            //NSLog(@"Saving records...");
            [self saveContext];
        }
    }
    [self saveContext];
    NSLog(@"Removed unselected emotions from all records.");
}



- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    
    [[self tableView] reloadData];
    
    if (selection){
        [[self tableView] selectRowAtIndexPath:selection animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else { // On first load, go to the bottom of the TableView (dates are in ascending order)
        NSUInteger lastSection;
        if ([[self.fetchedResultsController sections] count] > 0) {
            lastSection = [[self.fetchedResultsController sections] count] - 1;
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:lastSection] - 1) inSection:lastSection];
            [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        else {
            // lastSection = 0; // no records yet
            [self showFirstTimeScreen];
        }
    }
    [super viewWillAppear:animated];
}

- (void)showFirstTimeScreen {
    //Initial screen when no records
    MlAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) { // iPhone 4 inch screen
        self.firstTimeView = [[[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self options:nil] objectAtIndex:0];
    }
    else { // iPhone 3.5 inch screen
        self.firstTimeView = [[[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self options:nil] objectAtIndex:1];
    }
//    [self.firstTimeView setBounds:CGRectMake(delegate.window.bounds.origin.x, delegate.window.bounds.origin.y,delegate.window.bounds.size.width,delegate.window.bounds.size.height)];
 
    [delegate.window addSubview:self.firstTimeView];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(touchedFirstTimeScreen:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    self.firstTimeView.userInteractionEnabled = YES;
    [self.firstTimeView addGestureRecognizer:tapRecognizer];
}

- (void)touchedFirstTimeScreen: (id)sender {
    self.firstTimeView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    [self.tableView reloadData];

//    NSUInteger lastSection = [[self.fetchedResultsController sections] count] - 1;
//    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:lastSection] - 1) inSection:lastSection];
//    [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    [self insertNewObjectAndReturnReference:self];
    NSUInteger lastSection = [[self.fetchedResultsController sections] count] - 1;
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:lastSection] - 1) inSection:lastSection];
    [self.tableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.tableView selectRowAtIndexPath:scrollIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    [self tableView:self.tableView didSelectRowAtIndexPath:scrollIndexPath];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        // iPad doesn't segue, the detail view is always there
    }
    else { // iPhone
        [self performSegueWithIdentifier:@"showDetail" sender:sender];
    }
}

- (MoodLogEvents *) insertNewObjectAndReturnReference: (id) sender {
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    MoodLogEvents *newMood = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];

    // If appropriate, configure the new managed object.
    newMood.dateCreated = [NSDate date];
    newMood.date = newMood.dateCreated;
    
    // ((year * 1000) + month) -- store the header in a language-agnostic way
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:newMood.date];
    newMood.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
    newMood.editing = [NSNumber numberWithBool:NO];
    newMood.sliderValuesSet = [NSNumber numberWithBool:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    newMood.showFaces = [NSNumber numberWithBool:[defaults boolForKey:@"DefaultFacesState"]];
    newMood.showFacesEditing = [NSNumber numberWithBool:[defaults boolForKey:@"DefaultFacesEditingState"]];
    newMood.sortStyle = [defaults stringForKey:@"DefaultSortStyle"]; // Default sort style
    newMood.sortStyleEditing = [defaults stringForKey:@"DefaultSortStyleEditing"]; // Default sort style when editing
    
    // Save the context
    [self saveContext];
    
    return newMood;
}

- (IBAction)showWelcomeScreen:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AdditionalStoryboards" bundle:nil];
    UIViewController *welcomeViewController = [sb instantiateViewControllerWithIdentifier:@"welcomeNavigationController"];
    [welcomeViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:welcomeViewController animated:YES completion:NULL];
}

- (IBAction)showCharts:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AdditionalStoryboards" bundle:nil];
    UIViewController *chartViewController = [sb instantiateViewControllerWithIdentifier:@"chartViewController"];
    [chartViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:chartViewController animated:YES completion:NULL];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// Setting the cell height in the Storyboard doesn't set it in the running app, so I override heightForRowAtIndexPath
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return CELL_HEIGHT; // cell.bounds.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MlCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        [self saveContext];
    }
}

- (void) saveContext { // Save data to the database
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        MoodLogEvents *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = object;
        [[self.detailViewController myMoodCollectionViewController] refresh];
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
//    UIView *view = [[UIView alloc] initWithFrame:[cell frame]]; // Wrapping the cell in a UIView to avoid the "no index path for table cell being reused" message
//    [view addSubview:cell];

    UILabel *label = (UILabel *)[cell viewWithTag:100];
    NSString *header = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    static NSArray *monthSymbols = nil;
    
    if (!monthSymbols) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        monthSymbols = [formatter monthSymbols];
    }
    
    NSInteger numericSection = [header integerValue];
    
	NSInteger year = numericSection / 1000;
	NSInteger month = numericSection - (year * 1000);
	
	NSString *headerTitle = [NSString stringWithFormat:@"%@ %ld", [monthSymbols objectAtIndex:month-1], (long)year];

    
    [label setText:headerTitle];
    return (UIView *)cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MoodLogEvents *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
    else if ([[segue identifier] isEqualToString:@"mailView"]) {
        [(MlMailViewController *)[segue destinationViewController] setMasterViewController:self];
    }
}

#pragma mark - Fetched results controller

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
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
//    NSLog(@"Called beginUpdates");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
           break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//    NSLog(@"Called endUpdates.");
    [self.tableView endUpdates];
}

- (NSFetchedResultsController *)fetchedResultsControllerForEmotions {
    if (_fetchedResultsControllerForEmotions != nil) {
        return _fetchedResultsControllerForEmotions;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Emotions" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
//    NSPredicate *requestPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]]];
//    [fetchRequest setPredicate:requestPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"name" cacheName:nil]; // @"EmotionsCache"
    aFetchedResultsController.delegate = self;
    self.fetchedResultsControllerForEmotions = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsControllerForEmotions performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsControllerForEmotions;
}


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

#pragma mark cell configuration

- (void)configureCell:(MlCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSDate *today = [object valueForKey:@"date"];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];
    NSInteger day = [weekdayComponents day];
    NSInteger weekday = [weekdayComponents weekday];

    static NSArray *dayNames = nil;
    if (!dayNames) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        dayNames = [formatter weekdaySymbols];
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
            cell.calendarImage.hidden = NO;
            cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
            cell.weekdayLabel.text = [NSString stringWithFormat:@"%@", dayNames[weekday-1]];            
        }
        else {
            cell.dateLabel.text = @"";
            cell.weekdayLabel.text = @"";
            cell.calendarImage.hidden = YES;
        }
    }
    else {
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        cell.weekdayLabel.text = [NSString stringWithFormat:@"%@", dayNames[weekday-1]];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = NSLocalizedString(@"h:mm a", @"h:mm a date format");
    
    cell.timeLabel.text = [dateFormatter stringFromDate: today];
    
    // Fetch the Mood list for this journal entry
    NSSet *emotionsforEntry = object.relationshipEmotions; // Get all the emotions for this record
    NSArray *emotionArray = [[emotionsforEntry allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSString *selectedEms = [[NSString alloc] init];
    NSString *lastEm = [[NSString alloc] init];
    if ([emotionArray count] > 0) {
        NSMutableArray *mutableEmotionArray = [NSMutableArray arrayWithArray:emotionArray];
        // Treat the first one as special (no comma before)
        selectedEms = [((Emotions *)[mutableEmotionArray objectAtIndex:0]).name lowercaseString];
        // Treat the last emotion as special (preface with 'and' and end with '.')
        [mutableEmotionArray removeObjectAtIndex:0];
        if ([mutableEmotionArray count] > 0) {
            lastEm = [NSString stringWithFormat:NSLocalizedString(@" and %@.", @" and %@."), [((Emotions *)[mutableEmotionArray objectAtIndex:[mutableEmotionArray count] - 1]).name lowercaseString]];
            [mutableEmotionArray removeObjectAtIndex:[mutableEmotionArray count] - 1];
        }
        else {
            lastEm = NSLocalizedString(@".", @"period");
        }
        for (id emotion in mutableEmotionArray) {
            selectedEms = [selectedEms stringByAppendingFormat:@", %@", [((Emotions *)emotion).name lowercaseString]];
        }
        
    }
    NSMutableString *displayString = [[NSMutableString alloc] init];
    NSUInteger entryEnd = 0;
    NSMutableAttributedString *as;
    if (emotionArray) {
        [displayString appendFormat:NSLocalizedString(@"I feel %@%@\n", @"I feel %@%@\n -- in List view"), selectedEms, lastEm];
    }
    entryEnd = [displayString length];
    NSString *entry = [object valueForKey:@"journalEntry"];
    if (entry.length > 0) {
        [displayString appendFormat:@"%@\n", [object valueForKey:@"journalEntry"]];
    }
    as = [[NSMutableAttributedString alloc] initWithString:displayString];
    NSRange journalRange = NSMakeRange(entryEnd, [as length] - entryEnd);
    [as addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Italic" size:14] range:NSMakeRange(0,entryEnd)];
    [as addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] range:journalRange];
    [as addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:journalRange];
    cell.mainLabel.attributedText = as;
    
}

@end
