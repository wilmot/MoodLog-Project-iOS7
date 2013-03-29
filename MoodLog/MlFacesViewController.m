//
//  MlFacesViewController.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 2/5/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlFacesViewController.h"
#import "Prefs.h"

@interface MlFacesViewController ()

@end

@implementation MlFacesViewController

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
}

- (void) viewWillAppear:(BOOL)animated {
    [self selectButton]; // Highlight the correct button
    [self setFaces:[self.detailItem.showFaces boolValue]];
    self.detailItem.editing = [NSNumber numberWithBool:YES];
    [self saveContext];
    [self.myMoodCollectionViewController refresh];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MoodCollectionSegue2"]) {
        self.myMoodCollectionViewController = [segue destinationViewController]; // Getting a reference to the collection view
        ((MlMoodCollectionViewController *)[segue destinationViewController]).detailItem = self.detailItem;
    }
}

- (IBAction)sortABC:(id)sender {
    self.detailItem.sortStyle = alphabeticalSort;
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)sortGroup:(id)sender {
    self.detailItem.sortStyle = groupSort;
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)sortCBA:(id)sender {
    self.detailItem.sortStyle = reverseAlphabeticalSort;
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)sortShuffle:(id)sender {
    self.detailItem.sortStyle = shuffleSort;
    [self saveContext];
    [self selectButton];
    [self.myMoodCollectionViewController refresh];
}

- (void) selectButton {
    NSString *aButton = [self.detailItem valueForKey:@"sortStyle"];
    if ([aButton isEqualToString:alphabeticalSort]) {
        [self.sortABCButton setSelected:YES];
        [self.SortCBAButton setSelected:NO];
        [self.sortGroupButton setSelected:NO];
        [self.sortShuffleButton setSelected:NO];
    }
    else if ([aButton isEqualToString:reverseAlphabeticalSort]) {
        [self.sortABCButton setSelected:NO];
        [self.SortCBAButton setSelected:YES];
        [self.sortGroupButton setSelected:NO];
        [self.sortShuffleButton setSelected:NO];
        
    }
    else if ([aButton isEqualToString:groupSort]) {
        [self.sortABCButton setSelected:NO];
        [self.SortCBAButton setSelected:NO];
        [self.sortGroupButton setSelected:YES];
        [self.sortShuffleButton setSelected:NO];
    }
    else if ([aButton isEqualToString:shuffleSort]) {
        [self.sortABCButton setSelected:NO];
        [self.SortCBAButton setSelected:NO];
        [self.sortGroupButton setSelected:NO];
        [self.sortShuffleButton setSelected:YES];
    }
}

- (IBAction)toggleFaces:(id)sender {
    Boolean facesState = ![self.detailItem.showFaces boolValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setFaces:facesState];
    [defaults setBool:facesState forKey:@"DefaultFacesState"];
    [defaults synchronize];
    
}

- (void) setFaces:(BOOL)facesState {
    if (facesState == YES) {
        self.myMoodCollectionViewController.cellIdentifier = @"moodCellFaces";
    }
    else {
        self.myMoodCollectionViewController.cellIdentifier = @"moodCell";
    }
    self.detailItem.showFaces = [NSNumber numberWithBool:facesState]; // Save state in database
    [self.toggleFacesButton setSelected:facesState];
    [self saveContext];
    [self.myMoodCollectionViewController refresh];
}

- (IBAction)doneButtonPressed:(id)sender {
    self.detailItem.editing = [NSNumber numberWithBool:NO];
    [self saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveContext { // Save data to the database
    // Save the context.
    NSError *error = nil;
    if (![[self.detailItem managedObjectContext] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSortGroupButton:nil];
    [super viewDidUnload];
}
@end
