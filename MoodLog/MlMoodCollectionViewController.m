//
//  MlMoodCollectionViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/18/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlMoodCollectionViewController.h"
#import "MlCollectionViewCell.h"
#import "MlAppDelegate.h"
#import "MlDetailViewController.h"
#import "Emotions.h"
#import "MoodLogEvents.h"
#import "Prefs.h"
#import "MlMoodCollectionViewHeaderView.h"
#import "MlMoodDataItem.h"
#import "MlColorChoices.h"

// From http://stackoverflow.com/questions/56648/whats-the-best-way-to-shuffle-an-nsmutablearray
// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end

//  NSMutableArray_Shuffling.m

@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end

@interface MlMoodCollectionViewController ()

@end

@implementation MlMoodCollectionViewController

UIColor *normalColor;
UIColor *selectedColor;
NSString *check = @"✅";
NSArray *emotionArray;
NSMutableArray *mutableEmotionsFromPList;
MoodLogEvents *myLogEntry;

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
    normalColor = [UIColor colorWithRed:202.0f/255.0f
                                  green:255.0f/255.0f
                                   blue:199.0f/255.0f
                                  alpha:0.0f];
    //    MlFlowLayout *myLayout = [[MlFlowLayout alloc]init];
    //    [self.collectionView setCollectionViewLayout:myLayout animated:YES];
    
    if (!self.cellIdentifier) {
        self.cellIdentifier = @"moodCell";
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.currentParrotLevel = [defaults integerForKey:@"DefaultParrotLevel"];
    self.showColorsOnEmotions = [defaults boolForKey:@"DefaultFacesColorState"];
    
    self.faceImageDictionary = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).faceImageDictionary;

    // WWDC 2012 video introduction to UICollectionViews talks about registering the class
    // But apparently this isn't needed if I use Storyboards; instead I should set the "Prototype Cell" in the Storyboard
    //[self.collectionView registerClass:[MlCollectionViewCell class] forCellWithReuseIdentifier:@"moodCell"];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];

    // Get a reference to this Log Entry
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) { // iPad
        myLogEntry = ((MlDetailViewController *)([self parentViewController])).detailItem;
    }
    else { // iPhone
        myLogEntry = self.detailItem;
    }

    // Get the data from the database
    [self getMoodRecordsFromCoreData];

}

- (void) viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self updateMoodRecordsForLogEntry];
}

- (void) viewDidUnload {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void) refresh {

    NSPredicate *myFilter;
    NSNumber *parrotLevel =[NSNumber numberWithInt:self.currentParrotLevel];
    if (myLogEntry.editing.boolValue == YES) { // Editing
        myFilter = [NSPredicate predicateWithFormat:@"parrotLevel.intValue <= %@", parrotLevel];
        if ( [myLogEntry.sortStyleEditing isEqualToString:alphabeticalSort]) {
            emotionArray = [NSArray arrayWithObjects:[[mutableEmotionsFromPList filteredArrayUsingPredicate:myFilter] sortedArrayUsingSelector:@selector(compare:)], nil];
        }
        else if ([myLogEntry.sortStyleEditing isEqualToString:groupSort]) {
            // TODO: Find a more elegant way to accomplish the arrays within arrays
            NSPredicate *groupLove = [NSPredicate predicateWithFormat:@"(category == %@) AND (parrotLevel.intValue <= %@)", love, parrotLevel];
            NSPredicate *groupJoy = [NSPredicate predicateWithFormat:@"(category == %@) AND (parrotLevel.intValue <= %@)", joy, parrotLevel];
            NSPredicate *groupSurprise = [NSPredicate predicateWithFormat:@"(category == %@) AND (parrotLevel.intValue <= %@)", surprise, parrotLevel];
            NSPredicate *groupAnger = [NSPredicate predicateWithFormat:@"(category == %@) AND (parrotLevel.intValue <= %@)", anger, parrotLevel];
            NSPredicate *groupSadness = [NSPredicate predicateWithFormat:@"(category == %@) AND (parrotLevel.intValue <= %@)", sadness, parrotLevel];
            NSPredicate *groupFear = [NSPredicate predicateWithFormat:@"(category == %@) AND (parrotLevel.intValue <= %@)", fear, parrotLevel];

            NSArray *loveArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupLove] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *joyArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupJoy] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *surpriseArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupSurprise] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *angerArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupAnger] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *sadnessArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupSadness] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *fearArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupFear] sortedArrayUsingSelector:@selector(compare:)];
            emotionArray = [NSArray arrayWithObjects:loveArray,joyArray,surpriseArray,angerArray,sadnessArray,fearArray, nil];
        }
        else if ( [myLogEntry.sortStyleEditing isEqualToString:reverseAlphabeticalSort]) {
            emotionArray = [NSArray arrayWithObjects:[[mutableEmotionsFromPList filteredArrayUsingPredicate:myFilter] sortedArrayUsingSelector:@selector(reverseCompare:)], nil];
        }
        else if ([myLogEntry.sortStyleEditing isEqualToString:shuffleSort]) { // Shuffle
            NSMutableArray *emotionMutableArray;
            emotionMutableArray = [NSMutableArray arrayWithArray:[mutableEmotionsFromPList filteredArrayUsingPredicate:myFilter]]; // whatever order they happen to be in
            [emotionMutableArray shuffle];
            emotionArray = [NSArray arrayWithObjects:[NSArray arrayWithArray:emotionMutableArray], nil];
        }
    }
    else { // Not Editing
        myFilter = [NSPredicate predicateWithFormat:@"selected == %@ AND parrotLevel.intValue <= %@", [NSNumber numberWithBool: YES], [NSNumber numberWithInt:self.currentParrotLevel]];
        if ( [myLogEntry.sortStyle isEqualToString:alphabeticalSort]) {
            emotionArray = [NSArray arrayWithObjects:[[mutableEmotionsFromPList filteredArrayUsingPredicate:myFilter] sortedArrayUsingSelector:@selector(compare:)], nil];
        }
        else if ( [myLogEntry.sortStyle isEqualToString:groupSort]) {
            // TODO: Find a more elegant way to accomplish the arrays within arrays
            NSNumber *nYES = [NSNumber numberWithBool:YES];
            NSPredicate *groupLove = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@ AND parrotLevel.intValue <= %@", love, nYES, parrotLevel];
            NSPredicate *groupJoy = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@ AND parrotLevel.intValue <= %@", joy, nYES, parrotLevel];
            NSPredicate *groupSurprise = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@ AND parrotLevel.intValue <= %@", surprise, nYES, parrotLevel];
            NSPredicate *groupAnger = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@ AND parrotLevel.intValue <= %@", anger, nYES, parrotLevel];
            NSPredicate *groupSadness = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@ AND parrotLevel.intValue <= %@", sadness, nYES, parrotLevel];
            NSPredicate *groupFear = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@ AND parrotLevel.intValue <= %@", fear, nYES, parrotLevel];
            NSArray *loveArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupLove]  sortedArrayUsingSelector:@selector(compare:)];
            NSArray *joyArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupJoy] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *surpriseArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupSurprise] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *angerArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupAnger] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *sadnessArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupSadness] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *fearArray = [[mutableEmotionsFromPList filteredArrayUsingPredicate:groupFear] sortedArrayUsingSelector:@selector(compare:)];
            emotionArray = [NSArray arrayWithObjects:loveArray,joyArray,surpriseArray,angerArray,sadnessArray,fearArray, nil];
        }
        else if ( [myLogEntry.sortStyle isEqualToString:reverseAlphabeticalSort]) {
            emotionArray = [NSArray arrayWithObjects:[[mutableEmotionsFromPList filteredArrayUsingPredicate:myFilter] sortedArrayUsingSelector:@selector(reverseCompare:)], nil];
        }
        else if ([myLogEntry.sortStyle isEqualToString:shuffleSort]) { // Shuffle
            NSMutableArray *emotionMutableArray;
            emotionMutableArray = [NSMutableArray arrayWithArray:[mutableEmotionsFromPList filteredArrayUsingPredicate:myFilter]];
            [emotionMutableArray shuffle];
            emotionArray = [NSArray arrayWithObjects:[NSArray arrayWithArray:emotionMutableArray], nil];
        }
    }
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)longPress:(id)sender {
    UILongPressGestureRecognizer *gestureRecognizer = (UILongPressGestureRecognizer *)sender;
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Define", @"Define - pop up menu") action:@selector(showDefinition:)];
        
        CGPoint touchPoint = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
        MlMoodDataItem *aMood = [[emotionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        self.wordToDefine = aMood.mood;

        NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void)showDefinition:(id) sender {
    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:self.wordToDefine]) {
        self.referenceLibraryVC = [[UIReferenceLibraryViewController alloc] initWithTerm:self.wordToDefine];
        [self presentViewController:self.referenceLibraryVC animated:YES completion:^{self.isShowingDefinition = NO;}];
    }
}

- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (selector == @selector(showDefinition:)) {
        return YES;
    }
    return NO;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

# pragma mark - UICollectionView Delegate Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [emotionArray count];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    //    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    //    return [sectionInfo numberOfObjects];
    return [[emotionArray objectAtIndex:section] count];
}

// TODO: get rid of myLogEntry.editing.boolValue

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (myLogEntry.editing.boolValue == YES) {
        // get the mood from the active array of arrays
        MlMoodDataItem *aMood = [[emotionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        Boolean startingState = aMood.selected;
       // save the mood in the master array
        NSArray *matchingMoodsFromMaster = [mutableEmotionsFromPList filteredArrayUsingPredicate:[NSPredicate
                                              predicateWithFormat:@"self == %@", @"New"]];
        for (MlMoodDataItem *theMood in matchingMoodsFromMaster) { // generally there should only be one
            [theMood setValue:[NSNumber numberWithBool:!startingState] forKey:@"selected"];
        }
        [aMood setValue:[NSNumber numberWithBool:!startingState] forKey:@"selected"];
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (myLogEntry.editing.boolValue == YES) {
        if ([[emotionArray objectAtIndex:section] count] > 0 && ([myLogEntry.sortStyleEditing isEqualToString:groupSort])) {
            return CGSizeMake(0, 20);
        }
        else {
            return CGSizeZero;
        }
        
    } else {
        if ([[emotionArray objectAtIndex:section] count] > 0 && ([myLogEntry.sortStyle isEqualToString:groupSort])) {
            return CGSizeMake(0, 20);
        }
        else {
            return CGSizeZero;
        }
    }
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        MlMoodCollectionViewHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"moodCellHeader" forIndexPath:indexPath];
         if ([[emotionArray objectAtIndex:indexPath.section] count] > 0) {
            MlMoodDataItem *aMood = [[emotionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            headerView.headerLabel.text = aMood.category;
             if (self.showColorsOnEmotions) {
                 headerView.backgroundColor = [[MlColorChoices basicColors] objectForKey:aMood.category];
             }
             else {
                 headerView.backgroundColor = [UIColor grayColor];
             }
       }
        
        reusableview = headerView;
    }
    else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"moodCellFooter" forIndexPath:indexPath];
        reusableview = footerView;
    }
    return reusableview;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(10.0, 10.0);
    UIInterfaceOrientation orientation;
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if ([self.cellIdentifier isEqual: @"moodCellFaces"]){
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            size = CGSizeMake(110.0, 133.0);
        }
        else { // iPhone
            size = CGSizeMake(80.0, 114.0);
        }
    }
    else if ([self.cellIdentifier isEqual: @"moodCell"]) {
        //
        if ((orientation == UIDeviceOrientationPortrait) || ( orientation == UIDeviceOrientationPortraitUpsideDown)) {
            size = CGSizeMake(106.0, 32.0); // Portrait
        }
        else {
            size = CGSizeMake(112.0, 32.0); // Landscape iPhone5
        }
    }
    return size;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self.collectionView reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    MlCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    MlMoodDataItem *aMood = [[emotionArray objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row];
    
    if (aMood.selected) {
        // set the color of the bg to something selected
        if (self.showColorsOnEmotions) {
            [cell setBackgroundColor:[[MlColorChoices translucentColors: 0.4f] objectForKey:aMood.category]];
        }
        else {
            [cell setBackgroundColor:selectedColor];
        }
        [[cell moodName] setTextColor:[UIColor blackColor]];
        if (myLogEntry.editing.boolValue == YES) {
            [[cell checkMark] setHidden:NO];
            if ([self.cellIdentifier isEqual: @"moodCellFaces"]) {
                [[cell moodName] setText:[NSString stringWithFormat:@"%@", aMood.mood]];
                [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
                [[cell face] setImage:[self.faceImageDictionary objectForKey:[aMood valueForKey:@"mood"]]];
          }
            else { // no faces
                [[cell checkMark] setHidden:NO];
                [[cell moodName] setText:[NSString stringWithFormat:@"%@", aMood.mood]];
                [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
           }
        }
        else { // not editing
            [[cell checkMark] setHidden:YES];
            if ([self.cellIdentifier isEqual: @"moodCellFaces"]) {
                [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
                [[cell face] setImage:[self.faceImageDictionary objectForKey:[aMood valueForKey:@"mood"]]];
            }
            else {
                [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];               
            }
            [[cell moodName] setText:[NSString stringWithFormat:@"%@", aMood.mood]];
        }
    }
    else { // not selected
        // set the color to normal boring
        if (self.showColorsOnEmotions) {
            [cell setBackgroundColor:[[MlColorChoices translucentColors: 0.2f] objectForKey:aMood.category]];
        }
        else {
            [cell setBackgroundColor:normalColor];
        }
        [[cell moodName] setTextColor:[UIColor blackColor]];
        [[cell checkMark] setHidden:YES];
         if ([self.cellIdentifier isEqual: @"moodCellFaces"]) {
            [[cell moodName] setText:[NSString stringWithFormat:@"%@", aMood.mood]];
            [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
            [[cell face] setImage:[self.faceImageDictionary objectForKey:[aMood valueForKey:@"mood"]]];
       }
        else if ([self.cellIdentifier isEqual: @"moodCell"]) {
            [[cell moodName] setText:[NSString stringWithFormat:@"%@", aMood.mood]];
            [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        }
    }
    
    return cell;
}

# pragma mark CoreData-related methods

- (void) getMoodRecordsFromCoreData {
    NSSet *emotionsFromRecord;

    emotionsFromRecord = myLogEntry.relationshipEmotions; // Get all the emotions for this record
    NSArray *tempCopyOfEmotionsFromPList = ((MlAppDelegate *)[UIApplication sharedApplication].delegate).emotionsFromPList;
    mutableEmotionsFromPList = [[NSMutableArray alloc] initWithArray:tempCopyOfEmotionsFromPList copyItems:YES];
    NSPredicate *selectedPredicate = [NSPredicate predicateWithFormat:@"selected == YES"];
    NSSet *selectedEmotionsFromRecord = [emotionsFromRecord filteredSetUsingPredicate:selectedPredicate];
    for (Emotions *aMood in selectedEmotionsFromRecord) {
        NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"mood = %@",aMood.name];
        NSArray *result = [mutableEmotionsFromPList filteredArrayUsingPredicate:aPredicate];
        if ([result count] == 1) {
            MlMoodDataItem *thisMood = (MlMoodDataItem *)result[0];
            thisMood.selected = YES;
        } else {
            abort();
        }
    }
}

- (void) updateMoodRecordsForLogEntry {
    for (MlMoodDataItem *aMood in mutableEmotionsFromPList) {
        if (aMood.selected) {
            [self saveMoodRecord:aMood];
        }
        else {
            [self deleteMoodRecord:aMood];
        }
    }
    [self saveContext];
}

- (void) saveMoodRecord: (MlMoodDataItem *)aMood {
    NSPredicate *findTheEmotionPredicate = [NSPredicate predicateWithFormat:@"name = %@",aMood.mood];
    NSSet *matchingEmotions = [myLogEntry.relationshipEmotions filteredSetUsingPredicate:findTheEmotionPredicate];
    if ([matchingEmotions count] > 0) { // Clear out any existing records (winnowing duplicates)
        for (Emotions *emo in matchingEmotions) {
            [myLogEntry removeRelationshipEmotionsObject:emo];
            [[((MlAppDelegate *)[UIApplication sharedApplication].delegate) managedObjectContext] deleteObject:emo];
       }
    }
    // Add emotion to the record
    Emotions *emotion = [NSEntityDescription insertNewObjectForEntityForName:@"Emotions" inManagedObjectContext:[self.detailItem managedObjectContext]];
    emotion.name = aMood.mood;
    emotion.category = aMood.category;
    emotion.parrotLevel = [NSNumber numberWithInt:[aMood.parrotLevel integerValue]];
    emotion.feelValue = [NSNumber numberWithInt:[aMood.feelValue integerValue]];
    emotion.facePath = aMood.facePath;
    emotion.selected = [NSNumber numberWithBool:aMood.selected];
    emotion.logParent = myLogEntry; // current record
    [myLogEntry addRelationshipEmotionsObject:emotion];
}

- (void) deleteMoodRecord: (MlMoodDataItem *)aMood {
    // Delete emotion from the record
    NSPredicate *findTheEmotionPredicate = [NSPredicate predicateWithFormat:@"name = %@",aMood.mood];
    NSSet *matchingEmotions = [myLogEntry.relationshipEmotions filteredSetUsingPredicate:findTheEmotionPredicate];
    for (Emotions *emo in matchingEmotions) {
        [myLogEntry removeRelationshipEmotionsObject:emo];
        [[((MlAppDelegate *)[UIApplication sharedApplication].delegate) managedObjectContext] deleteObject:emo];
    }
}
- (void) saveContext { // Save data to the database
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // TODO: Remove the aborts()
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"An unknown error has occurred:  %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
