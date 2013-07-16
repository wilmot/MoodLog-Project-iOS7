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
    // WWDC 2012 video introduction to UICollectionViews talks about registering the class
    // But apparently this isn't needed if I use Storyboards; instead I should set the "Prototype Cell" in the Storyboard
    //[self.collectionView registerClass:[MlCollectionViewCell class] forCellWithReuseIdentifier:@"moodCell"];
}

- (void) viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void) refresh {
    NSSet *emotionsforEntry;
    // Fetch the Mood list for this journal entry
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        // iPad
        myLogEntry = ((MlDetailViewController *)([self parentViewController])).detailItem;
        emotionsforEntry = myLogEntry.relationshipEmotions; // Get all the emotions for this record
    }
    else {
        myLogEntry = self.detailItem;
        emotionsforEntry = myLogEntry.relationshipEmotions; // Get all the emotions for this record
    }
    
    // Set the background color for selected items
    if (myLogEntry.editing.boolValue == YES) {
        selectedColor = [UIColor colorWithRed:202.0f/255.0f
                                        green:202.0f/255.0f
                                         blue:202.0f/255.0f
                                        alpha:0.5f];
    }
    else {
        selectedColor = [UIColor colorWithRed:202.0f/255.0f
                                        green:202.0f/255.0f
                                         blue:202.0f/255.0f
                                        alpha:0.0f];
    }
    
    NSPredicate *myFilter = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool: YES]];
    if (myLogEntry.editing.boolValue == YES) { // Editing
        if ( [myLogEntry.sortStyleEditing isEqualToString:alphabeticalSort]) {
            emotionArray = [NSArray arrayWithObjects:[[emotionsforEntry allObjects] sortedArrayUsingSelector:@selector(compare:)], nil];
        }
        else if ([myLogEntry.sortStyleEditing isEqualToString:groupSort]) {
            // TODO: Find a more elegant way to accomplish the arrays within arrays
            NSPredicate *groupLove = [NSPredicate predicateWithFormat:@"category == %@", @"Love"];
            NSPredicate *groupJoy = [NSPredicate predicateWithFormat:@"category == %@", @"Joy"];
            NSPredicate *groupSurprise = [NSPredicate predicateWithFormat:@"category == %@", @"Surprise"];
            NSPredicate *groupAnger = [NSPredicate predicateWithFormat:@"category == %@", @"Anger"];
            NSPredicate *groupSadness = [NSPredicate predicateWithFormat:@"category == %@", @"Sadness"];
            NSPredicate *groupFear = [NSPredicate predicateWithFormat:@"category == %@", @"Fear"];
            NSArray *loveArray = [[[emotionsforEntry filteredSetUsingPredicate:groupLove] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *joyArray = [[[emotionsforEntry filteredSetUsingPredicate:groupJoy] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *surpriseArray = [[[emotionsforEntry filteredSetUsingPredicate:groupSurprise] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *angerArray = [[[emotionsforEntry filteredSetUsingPredicate:groupAnger] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *sadnessArray = [[[emotionsforEntry filteredSetUsingPredicate:groupSadness] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *fearArray = [[[emotionsforEntry filteredSetUsingPredicate:groupFear] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            emotionArray = [NSArray arrayWithObjects:loveArray,joyArray,surpriseArray,angerArray,sadnessArray,fearArray, nil];
        }
        else if ( [myLogEntry.sortStyleEditing isEqualToString:reverseAlphabeticalSort]) {
            emotionArray = [NSArray arrayWithObjects:[[emotionsforEntry allObjects] sortedArrayUsingSelector:@selector(reverseCompare:)], nil];
        }
        else if ([myLogEntry.sortStyleEditing isEqualToString:shuffleSort]) { // Shuffle
            NSMutableArray *emotionMutableArray;
            emotionMutableArray = [NSMutableArray arrayWithArray:[emotionsforEntry allObjects]]; // whatever order they happen to be in
            [emotionMutableArray shuffle];
            emotionArray = [NSArray arrayWithObjects:[NSArray arrayWithArray:emotionMutableArray], nil];
        }
    }
    else { // Not Editing
        if ( [myLogEntry.sortStyle isEqualToString:alphabeticalSort]) {
            emotionArray = [NSArray arrayWithObjects:[[[emotionsforEntry filteredSetUsingPredicate:myFilter] allObjects] sortedArrayUsingSelector:@selector(compare:)], nil];
        }
        else if ( [myLogEntry.sortStyle isEqualToString:groupSort]) {
            // TODO: Find a more elegant way to accomplish the arrays within arrays
            NSPredicate *groupLove = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@", @"Love", [NSNumber numberWithBool:YES]];
            NSPredicate *groupJoy = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@", @"Joy", [NSNumber numberWithBool:YES]];
            NSPredicate *groupSurprise = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@", @"Surprise", [NSNumber numberWithBool:YES]];
            NSPredicate *groupAnger = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@", @"Anger", [NSNumber numberWithBool:YES]];
            NSPredicate *groupSadness = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@", @"Sadness", [NSNumber numberWithBool:YES]];
            NSPredicate *groupFear = [NSPredicate predicateWithFormat:@"category == %@ AND selected == %@", @"Fear", [NSNumber numberWithBool:YES]];
            NSArray *loveArray = [[[emotionsforEntry filteredSetUsingPredicate:groupLove] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *joyArray = [[[emotionsforEntry filteredSetUsingPredicate:groupJoy] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *surpriseArray = [[[emotionsforEntry filteredSetUsingPredicate:groupSurprise] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *angerArray = [[[emotionsforEntry filteredSetUsingPredicate:groupAnger] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *sadnessArray = [[[emotionsforEntry filteredSetUsingPredicate:groupSadness] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            NSArray *fearArray = [[[emotionsforEntry filteredSetUsingPredicate:groupFear] allObjects] sortedArrayUsingSelector:@selector(compare:)];
            emotionArray = [NSArray arrayWithObjects:loveArray,joyArray,surpriseArray,angerArray,sadnessArray,fearArray, nil];
        }
        else if ( [myLogEntry.sortStyle isEqualToString:reverseAlphabeticalSort]) {
            emotionArray = [NSArray arrayWithObjects:[[[emotionsforEntry filteredSetUsingPredicate:myFilter] allObjects] sortedArrayUsingSelector:@selector(reverseCompare:)], nil];
        }
        else if ([myLogEntry.sortStyle isEqualToString:shuffleSort]) { // Shuffle
            NSMutableArray *emotionMutableArray;
            emotionMutableArray = [NSMutableArray arrayWithArray:[[emotionsforEntry filteredSetUsingPredicate:myFilter] allObjects]];
            [emotionMutableArray shuffle];
            emotionArray = [NSArray arrayWithObjects:[NSArray arrayWithArray:emotionMutableArray], nil];
        }
    }
    
//    UICollectionViewFlowLayout *myLayout = [[UICollectionViewFlowLayout alloc]init];
//    if ([self.cellIdentifier isEqual: @"moodCellFaces"]){
//        if (myLogEntry.editing.boolValue == YES) {
//            myLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//        }
//        else {
//            myLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        }
//    }
//    else {
//        myLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    }
//    [self.collectionView setCollectionViewLayout:myLayout animated:YES];

    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)longPress:(id)sender {
    CGPoint touchPoint = [sender locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    Emotions *aMood = [[emotionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:aMood.name]) {
        UIReferenceLibraryViewController *referenceLibraryVC = [[UIReferenceLibraryViewController alloc] initWithTerm:aMood.name];
        [self presentViewController:referenceLibraryVC animated:YES completion:nil];

    }
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (myLogEntry.editing.boolValue == YES) {
        MlDetailViewController *detailViewController = ((MlDetailViewController *)([self parentViewController]));
        
        Emotions *aMood = [[emotionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if ([aMood.selected floatValue]) { // if it's already selected
            [aMood setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
        }
        else {
            [aMood setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
        }
        // Save the context.
        NSError *error = nil;
        if (![[detailViewController.detailItem managedObjectContext] save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        detailViewController.detailItem.sortStyle = detailViewController.detailItem.sortStyle; // Hack to get the Master list to update
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
            Emotions *aMood = [[emotionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            headerView.headerLabel.text = aMood.category;
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
    
    if ([self.cellIdentifier isEqual: @"moodCellFaces"]){
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            size = CGSizeMake(110.0, 133.0);
        }
        else { // iPhone
            size = CGSizeMake(80.0, 114.0);
        }
    }
    else if ([self.cellIdentifier isEqual: @"moodCell"]) {
        size = CGSizeMake(96.0, 32.0);
    }
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    MlCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // Emotions *aMood = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Emotions *aMood = [[emotionArray objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row];
    NSString *facePath = [[NSBundle mainBundle] pathForResource:aMood.facePath ofType:@"png"];
    UIImage *myImage = [UIImage imageWithContentsOfFile:facePath];
    [[cell face] setImage:myImage];
    
    if ([aMood.selected floatValue]) {
        // set the color of the bg to something selected
        [cell setBackgroundColor:selectedColor];
        [[cell moodName] setTextColor:[UIColor blackColor]];
        if (myLogEntry.editing.boolValue == YES) {
            [[cell checkMark] setHidden:NO];
            if ([self.cellIdentifier isEqual: @"moodCellFaces"]) {
                [[cell moodName] setText:[NSString stringWithFormat:@"%@", aMood.name]];
                [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]];
           }
            else { // no faces
                [[cell moodName] setText:[NSString stringWithFormat:@"%@%@", check, aMood.name]];
                [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
           }
        }
        else { // not editing
            [[cell checkMark] setHidden:YES];
            if ([self.cellIdentifier isEqual: @"moodCellFaces"]) {
                [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
            }
            else {
                [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];               
            }
            [[cell moodName] setText:[NSString stringWithFormat:@"%@", aMood.name]];
        }
    }
    else { // not selected
        // set the color to normal boring
        [cell setBackgroundColor:normalColor];
        [[cell moodName] setTextColor:[UIColor blackColor]];
        [[cell checkMark] setHidden:YES];
         if ([self.cellIdentifier isEqual: @"moodCellFaces"]) {
            [[cell moodName] setText:[NSString stringWithFormat:@"%@", aMood.name]];
            [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        }
        else if ([self.cellIdentifier isEqual: @"moodCell"]) {
            [[cell moodName] setText:[NSString stringWithFormat:@"    %@", aMood.name]];
            [[cell moodName] setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        }
    }
    
    return cell;
}

@end
