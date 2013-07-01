//
//  MlJournalEditorViewController.m
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 6/30/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlJournalEditorViewController.h"

@interface MlJournalEditorViewController ()

@end

@implementation MlJournalEditorViewController

MoodLogEvents *mood;

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
    [self.journalTextView setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    mood = (MoodLogEvents *) self.detailItem;
    self.journalTextView.text = mood.journalEntry;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    mood.journalEntry = self.journalTextView.text;
    [self saveContext];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    mood.journalEntry = self.journalTextView.text;
    [self saveContext];
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

@end
