//
//  MlAppDelegate.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlMasterViewController.h"

@interface MlAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *moodList;
@property (strong, nonatomic) NSDictionary *moodListDictionary;
@property (strong, nonatomic) NSArray *moodDataList;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) MlMasterViewController *masterViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
