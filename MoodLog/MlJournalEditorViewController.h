//
//  MlJournalEditorViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 6/30/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
//

#import <UIKit/UIKit.h>
#import "MlDetailViewController.h"

@interface MlJournalEditorViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *journalTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *journalToolbar;

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) MlDetailViewController *detailViewController;

- (IBAction)pressDoneButton:(id)sender;
@end
