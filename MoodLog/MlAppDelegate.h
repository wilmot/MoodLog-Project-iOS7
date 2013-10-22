//
//  MlAppDelegate.h
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MlMasterViewController.h"

@interface MlAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *moodList;
@property (strong, nonatomic) NSDictionary *moodListDictionary;
@property (strong, nonatomic) NSArray *emotionsFromPList;
@property (strong, nonatomic) NSDictionary *faceImageDictionary;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) MlMasterViewController *masterViewController;
@property (nonatomic, assign) NSInteger badgeCount;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
