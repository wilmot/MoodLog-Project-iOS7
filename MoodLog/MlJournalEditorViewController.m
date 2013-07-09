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
    [self.journalTextView becomeFirstResponder];

}

- (void) keyboardDidShow:(NSNotification *)aNotification {
    NSLog(@"About to show keyboard");
    NSDictionary *info = [aNotification userInfo];
    CGRect keyboardRect = [self.view.window convertRect:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] toView:self.view];
    [self.journalTextView setFrame:CGRectMake(0,0,self.parentViewController.view.bounds.size.width,self.journalTextView.bounds.size.height - keyboardRect.size.height)];
}

- (void) keyboardWillHide:(NSNotification *)aNotification {
    NSLog(@"About to hide keyboard");
    CGRect statusBarFrame = [self.view.window convertRect:[UIApplication sharedApplication].statusBarFrame toView:self.view];
    [self.journalTextView setFrame:CGRectMake(0,0,self.parentViewController.view.bounds.size.width,self.parentViewController.view.bounds.size.height - self.navigationController.toolbar.frame.size.height - statusBarFrame.size.height)];
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (IBAction)pressDoneButton:(id)sender {
    [self.journalTextView resignFirstResponder];
    [self.journalToolbar setRightBarButtonItem:nil animated:YES];
}
@end
