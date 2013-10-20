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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    mood = (MoodLogEvents *) self.detailItem;
    self.journalTextView.text = mood.journalEntry;
    [self.journalToolbar setRightBarButtonItem:nil animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.journalTextView becomeFirstResponder]; // Show the keyboard after the view appears
}

- (void) keyboardDidShow:(NSNotification *)aNotification {
    NSDictionary *info = [aNotification userInfo];
    CGRect keyboardRect = [self.view.window convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.view];
    CGRect textViewNewRect = CGRectMake(0,0,self.parentViewController.view.bounds.size.width,self.parentViewController.view.bounds.size.height - keyboardRect.size.height);
    [self.journalTextView setFrame:textViewNewRect];
}

- (void) keyboardWillHide:(NSNotification *)aNotification {
    // CGRect statusBarFrame = [self.view.window convertRect:[UIApplication sharedApplication].statusBarFrame toView:self.view];
    // Might need this for iOS 6: [self.journalTextView setFrame:CGRectMake(0,0,self.parentViewController.view.bounds.size.width,self.parentViewController.view.bounds.size.height - self.navigationController.toolbar.frame.size.height - statusBarFrame.size.height)];
    [self.journalTextView setFrame:CGRectMake(0,0,self.parentViewController.view.bounds.size.width,self.parentViewController.view.bounds.size.height)];
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
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.journalToolbar setRightBarButtonItem:self.doneButton animated:YES];
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
        NSLog(@"An unknown error has occurred:  %@, %@", error, [error userInfo]);
        abort();
    }
}

- (IBAction)pressDoneButton:(id)sender {
    [self.journalTextView resignFirstResponder];
    [self.journalToolbar setRightBarButtonItem:nil animated:YES];
}

@end
