//
//  MlJournalEditorViewController.h
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 6/30/13.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlDetailViewController.h"

@interface MlJournalEditorViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *journalTextView;

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) MlDetailViewController *detailViewController;

@end
