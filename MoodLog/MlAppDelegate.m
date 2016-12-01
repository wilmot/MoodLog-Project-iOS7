//
//  MlAppDelegate.m
//  MoodLog
//
//  Created by Barry A. Langdon-Lassagne on 10/16/12.
//  Copyright (c) 2013 Barry A. Langdon-Lassagne.
//  See LICENSE.rtf for full license agreement.
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
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];

    }

    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"MoodList" ofType:@"plist"];
    NSString *faceFullPath;
    NSMutableDictionary *faceImageMutableDictionary = [[NSMutableDictionary alloc] init];
   self.moodListDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    self.emotionsFromPList = [[NSArray alloc] init];
    for (id mood in self.moodListDictionary) {
        MlMoodDataItem  *aMoodDataItem = [[MlMoodDataItem alloc] init];
        aMoodDataItem.mood = mood;
        aMoodDataItem.facePath = [[self.moodListDictionary valueForKey:mood] valueForKey:@"facePath"];
        faceFullPath = [[NSBundle mainBundle] pathForResource:aMoodDataItem.facePath ofType:@"png"];
        [faceImageMutableDictionary setObject:[UIImage imageWithContentsOfFile:faceFullPath] forKey:mood];
       aMoodDataItem.feelValue = [[self.moodListDictionary valueForKey:mood] valueForKey:@"feelValue"];
        aMoodDataItem.parrotLevel = [[self.moodListDictionary valueForKey:mood] valueForKey:@"parrotLevel"];
        aMoodDataItem.category = [[self.moodListDictionary valueForKey:mood] valueForKey:@"category"];
        aMoodDataItem.selected = FALSE;
        self.emotionsFromPList = [self.emotionsFromPList arrayByAddingObject:aMoodDataItem];
    }
    self.faceImageDictionary = [faceImageMutableDictionary copy]; // For performance, I load all the faces into memory at the beginning, so when scrolling through the faces CollectionView it doesn't have to load them all the time
    
    // See if there are any defaults and register some if not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id testObject = [defaults objectForKey:@"MailSliderPinnedToNewest"]; // always test the newest default
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

        // Defaults for Reminders
        [defaults setBool:NO forKey:@"DefaultRandomRemindersOn"];
        [defaults setInteger:3 forKey:@"DefaultRandomTimesPerDay"];
        NSDate *quietStart = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: quietStart];
        components.hour = 21;
        components.minute = 30;
        quietStart = [gregorian dateFromComponents: components];
        [defaults setObject:quietStart forKey:@"DefaultRandomQuietStartTime"];
        NSDate *quietEnd = [NSDate date];
        components = [gregorian components: NSUIntegerMax fromDate: quietEnd];
        components.hour = 9;
        components.minute = 00;
        quietEnd = [gregorian dateFromComponents: components];
        [defaults setObject:quietEnd forKey:@"DefaultRandomQuietEndTime"];
        [defaults setInteger:20 forKey:@"DefaultDelayMinutes"];
        [defaults setInteger:2 forKey:@"DefaultParrotLevel"];
        [defaults setBool:YES forKey:@"DefaultFacesColorState"];

        NSDate *remindersTime0 = [NSDate date];
        components = [gregorian components: NSUIntegerMax fromDate: quietEnd];
        components.hour = 8;
        components.minute = 00;
        remindersTime0 = [gregorian dateFromComponents: components];
        [defaults setBool:NO forKey:@"RemindersTime0On"];
        [defaults setObject:remindersTime0 forKey:@"RemindersTime0"];
 
        NSDate *remindersTime1 = [NSDate date];
        components = [gregorian components: NSUIntegerMax fromDate: quietEnd];
        components.hour = 13;
        components.minute = 00;
        remindersTime1 = [gregorian dateFromComponents: components];
        [defaults setBool:NO forKey:@"RemindersTime1On"];
        [defaults setObject:remindersTime1 forKey:@"RemindersTime1"];

        NSDate *remindersTime2 = [NSDate date];
        components = [gregorian components: NSUIntegerMax fromDate: quietEnd];
        components.hour = 19;
        components.minute = 00;
        remindersTime2 = [gregorian dateFromComponents: components];
        [defaults setBool:NO forKey:@"RemindersTime2On"];
        [defaults setObject:remindersTime2 forKey:@"RemindersTime2"];
        
        // Email settings
        [defaults setFloat:0.0 forKey:@"DefaultMailStartValue"];
        [defaults setFloat:0.0 forKey:@"DefaultMailEndValue"];
        [defaults setBool:NO forKey:@"MailLatestButtonOn"];
        [defaults setBool:NO forKey:@"Mail7DayButtonOn"];
        [defaults setBool:NO forKey:@"Mail30DayButtonOn"];
        [defaults setBool:NO forKey:@"MailAllButtonOn"];
        [defaults setBool:NO forKey:@"MailSliderPinnedToNewest"];

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
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    ((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount = 0;
    [self saveContext]; // Save data
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
//    if (((long)((MlAppDelegate *)[UIApplication sharedApplication].delegate).badgeCount) > 0) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mood Log", @"Application Title")
                                                        message:NSLocalizedString(@"Create a new entry to record your current mood.", @"Text to show in the reminder notification")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"Close", @"Close button text")
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
        // TODO: Implement random reminders
//        NSDate *quietStart = (NSDate *)[defaults objectForKey:@"DefaultRandomQuietStartTime"];
//        NSDate *quietEnd = (NSDate *)[defaults objectForKey:@"DefaultRandomQuietEndTime"];
//        NSInteger timesPerDay = [defaults integerForKey:@"DefaultRandomTimesPerDay"];
    }
    else {
        // Nothing
    }

}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving Mood Log data", @"Core data saving error alert title")
                                        message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
            [alertView show];
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error finding Mood Log data", @"Core data persistent store coordinator error alert title")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"An unknown error has occurred:  %@, %@.\n\n Report this issue to support@voyageropen.com", @"Core Data saving error alert text"), error, [error userInfo]] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK button") otherButtonTitles:nil];
        [alertView show];
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
