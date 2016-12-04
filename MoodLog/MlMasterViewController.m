//
//  MlMasterViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
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
NSPredicate *filterPredicate = nil;


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
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (MlDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.searchController.searchBar.scopeButtonTitles = @[@"All", @"Moods", @"Text"];
    self.tableView.tableHeaderView = self.searchController.searchBar;

    // Used for testing and debugging:
    //[self updateOldRecords];
    //[self deleteUnselectedEmotionsFromOldRecords];
    //[self deleteEmotionsWithNullParent];
    
    CELL_HEIGHT = [[self.tableView dequeueReusableCellWithIdentifier:@"Cell"] bounds].size.height;

}

- (void)fetch {
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
        abort();
    }
}

- (void) updateSearch {
    if (self.searchController.isActive && ![self.searchController.searchBar.text isEqual: @""]) {
        switch (self.searchController.searchBar.selectedScopeButtonIndex) {
            case SearchTabItemAll:
                filterPredicate = [NSPredicate predicateWithFormat:@"journalEntry CONTAINS[cd] %@ OR relationshipEmotions.name CONTAINS[cd] %@", self.searchController.searchBar.text, self.searchController.searchBar.text];
                [self.fetchedResultsController.fetchRequest setPredicate:filterPredicate];
                [self fetch];
                break;
            case SearchTabItemMoods:
                filterPredicate = [NSPredicate predicateWithFormat:@"relationshipEmotions.name CONTAINS[cd] %@", self.searchController.searchBar.text];
                [self.fetchedResultsController.fetchRequest setPredicate:filterPredicate];
                [self fetch];
                break;
            case SearchTabItemText:
                filterPredicate = [NSPredicate predicateWithFormat:@"journalEntry CONTAINS[cd] %@", self.searchController.searchBar.text];
                [self.fetchedResultsController.fetchRequest setPredicate:filterPredicate];
                [self fetch];
                break;
            default:
                break;
        }
    }
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (self.searchController.isActive && ![self.searchController.searchBar.text isEqual: @""]) {
        [self updateSearch];
    }
    else { // Fetch all the records
        [self.fetchedResultsController.fetchRequest setPredicate:nil];
        [self fetch];
        [self.tableView reloadData];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearch];
}

- (void) updateOldRecords {
    NSArray *emotionsFromPList = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).emotionsFromPList;
    NSDateComponents *components;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSLog(@"Debugging: Running the updateOldRecords method. Turn this off after you've run it on your data.");
    int i = 0;
    for (MoodLogEvents *object in [[self fetchedResultsController] fetchedObjects]) {
        NSSet *emotions = object.relationshipEmotions;
        for(Emotions *emotion in emotions) {
            for (MlMoodDataItem *mood in emotionsFromPList) {
                if ([emotion.name isEqualToString:mood.mood]) {
                    emotion.category = mood.category;
                    emotion.parrotLevel = [NSNumber numberWithInt:(int)[mood.parrotLevel integerValue]];
                    emotion.feelValue = [NSNumber numberWithInt:(int)[mood.feelValue integerValue]];
                    emotion.facePath = mood.facePath;
                }
            }
            
        }
        // Make sure the header reflects the current date
        components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:object.date];
        object.header = [NSString stringWithFormat:@"%ld", (long)([components year] * 1000) + [components month]];
        if (i++%10 == 0) {
            NSLog(@"Debugging: Saving records...");
            [self saveContext];
        }
    }
    [self saveContext];
    NSLog(@"Debugging: Updated all records.");
}

- (void) deleteUnselectedEmotionsFromOldRecords {
    NSArray *emotionsFromPList = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).emotionsFromPList;
    NSLog(@"Debugging: Running the deleteUnselectedEmotionsFromOldRecords method. Turn this off after you've run it on your data.");
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
            NSLog(@"Debugging: Saving records...");
            [self saveContext];
        }
    }
    [self saveContext];
    NSLog(@"Debugging: Removed unselected emotions from all records.");
}

- (void) deleteEmotionsWithNullParent {
    MlAppDelegate *delegate = (MlAppDelegate *)[[UIApplication sharedApplication] delegate];
    int i = 0;
    NSArray *allTheEmotions = [[self fetchedResultsControllerForEmotions] fetchedObjects];
    NSLog(@"Debugging: Running the deleteEmotionsWithNullParent method. Processing %lu records", (unsigned long)[allTheEmotions count]);
    for (Emotions *anEmotion in allTheEmotions) {
        if (anEmotion.logParent == NULL) {
          [[delegate managedObjectContext] deleteObject:anEmotion];

        }
        else {
        }
        if (i++%20 == 0) {
            [self saveContext];
        }
    }
    [self saveContext];
    NSLog(@"Debugging: Removed unselected emotions from all records.");
}

- (void)scrollToTopButDontShowSearchBar {
    [self.tableView setContentOffset:CGPointMake(0, self.searchController.searchBar.frame.size.height) animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    
    [[self tableView] reloadData];
    
    if (selection){
        [[self tableView] selectRowAtIndexPath:selection animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else { // On first load, go to the top of the TableView but hide SearchBar (dates are in descending order)
        if ([[self.fetchedResultsController sections] count] > 0) {
            [self scrollToTopButDontShowSearchBar];
        }
        else {
            [self showFirstTimeScreen];
        }
    }
    [super viewWillAppear:animated];
}

- (void)showFirstTimeScreen {
    //Initial screen when no records
    MlAppDelegate *delegate = (MlAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) { // iPhone 4 inch screen
        self.firstTimeView = [[[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self options:nil] objectAtIndex:0];
    }
    else { // iPhone 3.5 inch screen (in case it needs to be different)
        self.firstTimeView = [[[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self options:nil] objectAtIndex:0];
    }
 
    [delegate.window addSubview:self.firstTimeView];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(touchedFirstTimeScreen:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    self.firstTimeView.userInteractionEnabled = YES;
    [self.firstTimeView addGestureRecognizer:tapRecognizer];
}

- (void)touchedFirstTimeScreen: (id)sender {
    // Fade out
    [UIView animateWithDuration:1.0
                                 animations:^{self.firstTimeView.alpha = 0;}
                                 completion:^(BOOL finished){
                                     self.firstTimeView.hidden = YES;
                                     [self insertNewObject:self]; // Create a new record to start the user on their way
                                 }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    [self insertNewObjectAndReturnReference:self];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
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
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:newMood.date];
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated { // Updates the appearance of the Edit|Done button item as necessary. Clients who override it must call super first.
    [super setEditing:editing animated:animated];
    if (!editing) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
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

- (void)saveContext { // Save data to the database
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving Mood Log data", @"Core data saving error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
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
    return (UIView *)cell.contentView;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"header" cacheName:nil]; //mainCacheName
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    [self fetch];
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
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
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
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
    [self fetch];
    
    return _fetchedResultsControllerForEmotions;
}

#pragma mark cell configuration

- (void)configureCell:(MlCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MoodLogEvents *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSDate *today = [object valueForKey:@"date"];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
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
        [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:oldToday];
        NSInteger oldDay = [oldWeekdayComponents day];
        if (oldDay != day) {
            cell.calendarImage.hidden = NO;
            cell.dateLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
            cell.weekdayLabel.text = [NSString stringWithFormat:@"%@", dayNames[weekday-1]];            
        }
        else {
            cell.calendarImage.hidden = YES;
            cell.dateLabel.text = @"";
            cell.weekdayLabel.text = @"";
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
    [as addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:14] range:NSMakeRange(0,entryEnd)];
    [as addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] range:journalRange];
    [as addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:journalRange];
    cell.mainLabel.attributedText = as;
    
}

@end
