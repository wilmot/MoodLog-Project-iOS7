//
//  MlAppDelegate.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2012 Barry A. Langdon-Lassagne. All rights reserved.
//

#import "MlAppDelegate.h"

#import "MlMoodDataItem.h"
#import "MoodLogEvents.h"
#import "Prefs.h"

@implementation MlAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize masterViewController = _masterViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        _masterViewController = (MlMasterViewController *)masterNavigationController.topViewController;
        _masterViewController.managedObjectContext = self.managedObjectContext;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        _masterViewController = (MlMasterViewController *)navigationController.topViewController;
        _masterViewController.managedObjectContext = self.managedObjectContext;
//        [navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.03 green:0.45 blue:0.08 alpha:1.0]];
    }

    
//    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"MoodList" ofType:@"plist"];
//    self.moodList = [NSArray arrayWithContentsOfFile:plistPath];
//    self.moodDataList = [[NSArray alloc] init];
//    for (id mood in self.moodList) {
//        MlMoodDataItem  *aMoodDataItem = [[MlMoodDataItem alloc] init];
//        aMoodDataItem.mood = mood;
//        aMoodDataItem.selected = FALSE;
//        self.moodDataList = [self.moodDataList arrayByAddingObject:aMoodDataItem];
//    }
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"MoodList" ofType:@"plist"];
    self.moodListDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    self.moodDataList = [[NSArray alloc] init];
    for (id mood in self.moodListDictionary) {
        MlMoodDataItem  *aMoodDataItem = [[MlMoodDataItem alloc] init];
        aMoodDataItem.mood = mood;
        aMoodDataItem.facePath = [[self.moodListDictionary valueForKey:mood] valueForKey:@"facePath"];
        aMoodDataItem.feelValue = [[self.moodListDictionary valueForKey:mood] valueForKey:@"feelValue"];
        aMoodDataItem.parrotLevel = [[self.moodListDictionary valueForKey:mood] valueForKey:@"parrotLevel"];
        aMoodDataItem.category = [[self.moodListDictionary valueForKey:mood] valueForKey:@"category"];
        aMoodDataItem.selected = FALSE;
        self.moodDataList = [self.moodDataList arrayByAddingObject:aMoodDataItem];
    }
    
    
    // See if there are any defaults and register some if not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id testObject = [defaults objectForKey:@"DefaultDelayMinutes"]; // always test the newest default
	if (testObject == nil) {
        [defaults setInteger:0 forKey:@"ChartSegmentState"];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [defaults setBool:YES forKey:@"DefaultFacesState"];
        }
        else {
            [defaults setBool:NO forKey:@"DefaultFacesState"];
        }
        [defaults setBool:YES forKey:@"DefaultFacesEditingState"];
        [defaults setObject:groupSort forKey:@"DefaultSortStyle"];
        [defaults setObject:groupSort forKey:@"DefaultSortStyleEditing"];
        [defaults setFloat:0.0 forKey:@"DefaultMailStartValue"];
        [defaults setFloat:0.0 forKey:@"DefaultMailEndValue"];
        // Defaults for Reminders
        [defaults setBool:NO forKey:@"DefaultRandomRemindersOn"];
        [defaults setInteger:3 forKey:@"DefaultRandomTimesPerDay"];
        NSDate *quietStart = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: quietStart];
        components.hour = 21;
        components.minute = 30;
        quietStart = [gregorian dateFromComponents: components];
        [[NSUserDefaults standardUserDefaults] setObject:quietStart forKey:@"DefaultRandomQuietStartTime"];
        NSDate *quietEnd = [NSDate date];
        components = [gregorian components: NSUIntegerMax fromDate: quietEnd];
        components.hour = 9;
        components.minute = 00;
        quietEnd = [gregorian dateFromComponents: components];
        [[NSUserDefaults standardUserDefaults] setObject:quietEnd forKey:@"DefaultRandomQuietEndTime"];
        [defaults setInteger:20 forKey:@"DefaultDelayMinutes"];

		[[NSUserDefaults standardUserDefaults] synchronize];
	}
    
    // Handle launching via a local notification
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"MyAlertView"
//                                                            message:@"App was launched via a local notification."
//                                                           delegate:self cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
       // [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    self.badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"App has been backgrounded. Badge #=%ld, badgeCount=%ld, will be set to zero",(long)[UIApplication sharedApplication].applicationIconBadgeNumber, (long)((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    ((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount = 0;
    [self saveContext]; // Save data
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"App will enter foreground. Badge #=%ld, badgeCount=%ld, will be set to zero",(long)[UIApplication sharedApplication].applicationIconBadgeNumber, (long)((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount);
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    ((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self setUpRandomLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"App received a didReceiveLocalNotification. Badge #=%ld, badgeCount=%ld. Setting them to zero.",(long)[UIApplication sharedApplication].applicationIconBadgeNumber,(long)((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount);
//    if (((long)((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount) > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mood Log"
                                                            message:@"Create a new entry to record your current mood."
                                                           delegate:self cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
        [alertView show];
//    }
    notification.applicationIconBadgeNumber = 0; // Reset badge
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    ((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount = 0;
}

- (void) setUpRandomLocalNotifications {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL randomRemindersOn = [defaults boolForKey:@"DefaultRandomRemindersOn"];
    if (randomRemindersOn) {
        NSDate *quietStart = (NSDate *)[defaults objectForKey:@"DefaultRandomQuietStartTime"];
        NSDate *quietEnd = (NSDate *)[defaults objectForKey:@"DefaultRandomQuietEndTime"];
        NSInteger timesPerDay = [defaults integerForKey:@"DefaultRandomTimesPerDay"];
        NSLog(@"Times/Day: %ld, Quiet Time Starts: %@, Ends: %@",(long)timesPerDay, quietStart, quietEnd);
    }
    else {
        NSLog(@"Random reminders are off");
    }

}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
            // TODO: Remove the aborts()
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MoodLog" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MoodLog.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
