//
//  MlMoodCollectionViewController.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/18/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoodLogEvents.h"

@interface MlMoodCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) MoodLogEvents *detailItem;
@property (strong, nonatomic) UIReferenceLibraryViewController *referenceLibraryVC;
@property(nonatomic, assign) BOOL isShowingDefinition;
@property(nonatomic, assign) BOOL showColorsOnEmotions;
@property(nonatomic, assign) int currentParrotLevel;
@property (strong, nonatomic) NSString *wordToDefine;
@property (strong, nonatomic) NSDictionary *faceImageDictionary; //reference to the delegate's dictionary of faces


- (void) refresh;
- (IBAction)longPress:(id)sender;

@end
