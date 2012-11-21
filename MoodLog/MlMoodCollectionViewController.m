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
                                  alpha:1.0f];
    selectedColor = [UIColor colorWithRed:162.0f/255.0f
                                    green:235.0f/255.0f
                                     blue:180.0f/255.0f
                                    alpha:1.0f];
//    MlFlowLayout *myLayout = [[MlFlowLayout alloc]init];
//    [self.collectionView setCollectionViewLayout:myLayout animated:YES];

    if (!self.cellIdentifier) {
        self.cellIdentifier = @"moodCell";
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void) refresh {
    // Fetch the Mood list for this journal entry
    MoodLogEvents *myLogEntry = ((MlDetailViewController *)([self parentViewController])).detailItem;
    NSSet *emotionsforEntry = myLogEntry.relationshipEmotions; // Get all the emotions for this record
    
    if ( [myLogEntry.sortStyle isEqualToString:alphabeticalSort]) {
        emotionArray = [[emotionsforEntry allObjects] sortedArrayUsingSelector:@selector(compare:)];
    }
    else if ( [myLogEntry.sortStyle isEqualToString:reverseAlphabeticalSort]) {
        emotionArray = [[emotionsforEntry allObjects] sortedArrayUsingSelector:@selector(reverseCompare:)];
    }
    else if ([myLogEntry.sortStyle isEqualToString:shuffleSort]) { // Shuffle
        NSMutableArray *emotionMutableArray = [NSMutableArray arrayWithArray:[emotionsforEntry allObjects]]; // whatever order they happen to be in
        [emotionMutableArray shuffle];
        emotionArray = [NSArray arrayWithArray:emotionMutableArray];
    }
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    return [sectionInfo numberOfObjects];
    return [emotionArray count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MlDetailViewController *detailViewController = ((MlDetailViewController *)([self parentViewController]));

    [[detailViewController entryLogTextView] resignFirstResponder];
    Emotions *aMood = [emotionArray objectAtIndex:indexPath.row];
    if ([aMood.selected floatValue]) { // if it's already selected
       // aMood.selected = [NSNumber numberWithBool:NO];
        [aMood setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
    }
    else {
        //aMood.selected = [NSNumber numberWithBool:YES];
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

#pragma mark - Delegate methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(10.0, 10.0);
    
    if (self.cellIdentifier == @"moodCell") {
        size = CGSizeMake(96.0, 18.0);
    }
    else if (self.cellIdentifier == @"moodCellFaces"){
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            size = CGSizeMake(86.0, 116.0);
        }
        else { // iPhone
            size = CGSizeMake(98.0, 117.0);
        }
    }
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    MlCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
        
    // Configure the cell...
    // Emotions *aMood = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Emotions *aMood = [emotionArray objectAtIndex:indexPath.row];

    if ([aMood.selected floatValue]) {
        // set the color of the bg to something selected
        [[cell moodName] setBackgroundColor:selectedColor];
        [[cell moodName] setTextColor:[UIColor blackColor]];
        [[cell moodName] setFont:[UIFont boldSystemFontOfSize:14.0]];
        [[cell moodName] setText:[NSString stringWithFormat:@"%@%@",check, aMood.name]];
    }
    else {
        // set the color to normal boring
        [[cell moodName] setBackgroundColor:normalColor];
        [[cell moodName] setTextColor:[UIColor blackColor]];
        [[cell moodName] setFont:[UIFont systemFontOfSize:14.0]];
        [[cell moodName] setText:[NSString stringWithFormat:@"    %@", aMood.name]];
    }

    
    return cell;
}

@end
