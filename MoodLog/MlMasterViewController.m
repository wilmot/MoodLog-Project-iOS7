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

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.addButton.action = @selector(insertNewObject:);
    self.addButton.target = self;
    self.navigationItem.rightBarButtonItem = self.addButton;
    self.detailViewController = (MlDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.searchController.searchBar.scopeButtonTitles = @[@"All", @"Emotions", @"Text"];
    if (@available(iOS 11, *)) {
        self.navigationItem.searchController = self.searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    }
    else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }

    // Used for testing and debugging:
    //[self updateOldRecords];
    //[self deleteUnselectedEmotionsFromOldRecords];
    //[self deleteEmotionsWithNullParent];
    
    CELL_HEIGHT = [[self.tableView dequeueReusableCellWithIdentifier:@"Cell"] bounds].size.height;
    
    if ([[self.fetchedResultsController sections] count] > 0) {
        [self scrollToTopButDontShowSearchBar];
    }
    else {
        [self showFirstTimeScreen];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
    [self scrollToTopButDontShowSearchBar];
    self.navigationItem.rightBarButtonItem.enabled = NO; // Work around a bug where the 'New' button is grayed out when returning from the DetailView
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)fetch {
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
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
            case SearchTabItemEmotions:
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
    if (@available(iOS 11, *)) {
        if ([[self.fetchedResultsController sections] count] > 0) { // If there are any records
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    else { // Old behavior
        if ([[self.fetchedResultsController sections] count] > 0) { // If there are any records
            if ((self.tableView.contentOffset.y >= 0) || (self.tableView.contentOffset.y == -20)) {
                [self.tableView setContentOffset:CGPointMake(0, self.searchController.searchBar.frame.size.height) animated:NO];
            }
            else {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
    }
}

- (void)showFirstTimeScreen {
    //Initial screen when no records
    MlAppDelegate *delegate = (MlAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *welcomeView = [[[NSBundle mainBundle] loadNibNamed:@"WelcomeView" owner:self options:nil] objectAtIndex:0];
    self.firstTimeView = welcomeView;
    
    self.firstTimeView.translatesAutoresizingMaskIntoConstraints = NO;
    welcomeView.bounds = self.view.bounds;
    [delegate.window addSubview:welcomeView];
    [delegate.window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[welcomeView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(welcomeView)]];
    [delegate.window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[welcomeView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(welcomeView)]];

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
    MoodLogEvents *event = [self insertNewObjectAndReturnReference:self];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        // iPad doesn't segue, the detail view is always there
    }
    else { // iPhone
        [self performSegueWithIdentifier:@"showDetail" sender:event];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    [self.tableView setContentOffset:CGPointMake(0, -20) animated:NO]; // Magic number related to the height of the header bars (e.g. December 2016)
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
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MoodLogEvents *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete Entry", @"Delete Entry") message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the entry dated '%@'? This action cannot be undone.", @"Are you sure you want to delete the entry dated '%@'? This action cannot be undone."), [self prettyDateAndTimeObjC:event.date]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     // Do nothing on Cancel
                                 }];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     [self.managedObjectContext deleteObject:event];
                                     [self saveContext];
                                     [self.tableView reloadData];
                                     
                                 }];
        [alert addAction:cancel];
        [alert addAction:delete];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)saveContext { // Save data to the database
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"Error retrieving Mood Log data", @"Core data retrieving error alert title")
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
    MoodLogEvents *object;
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        if ([sender isMemberOfClass:[MoodLogEvents class]]) {
            object = sender;
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        }
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
        cell.calendarImage.hidden = NO;
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
        
        
        if (([mutableEmotionArray count] > 0) && ([mutableEmotionArray count] <= 3)) {
            lastEm = [NSString stringWithFormat:NSLocalizedString(@" and %@.", @" and %@."), [((Emotions *)[mutableEmotionArray objectAtIndex:[mutableEmotionArray count] - 1]).name lowercaseString]];
            [mutableEmotionArray removeObjectAtIndex:[mutableEmotionArray count] - 1];
        }
        else if ([mutableEmotionArray count ] > 3) {
            lastEm = @"...";
            [mutableEmotionArray removeObjectAtIndex:[mutableEmotionArray count] - 1];
        }
        else { // 0
            lastEm = NSLocalizedString(@".", @"period");
        }
        if (mutableEmotionArray.count > 3) {
            // Just show the first few
            for (int i=0; i<3; i++) {
                Emotions *emotion = mutableEmotionArray[i];
                selectedEms = [selectedEms stringByAppendingFormat:@", %@", [((Emotions *)emotion).name lowercaseString]];
           }
        }
        else {
            for (id emotion in mutableEmotionArray) {
                selectedEms = [selectedEms stringByAppendingFormat:@", %@", [((Emotions *)emotion).name lowercaseString]];
            }
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

- (NSString *)prettyDateAndTimeObjC:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/YY hh:mm:ss a";
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

@end
