//
//  WDAppDelegate.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 25/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDAppDelegate.h"
#import "WDWordDiary.h"
#import "WDWord.h"
#import "WDPalette.h"
#import "WDStyle.h"
//#import "WDAllWordsScreenViewController.h"
//#import "WDSelectedWordScreenViewController.h"
#import "WDWordScreenViewController.h"

@interface WDAppDelegate()

- (void) prepareWordDiaryAtLaunch;
- (void) prepareRootViewController;
- (void) createDebugWords;
- (void) createDebugWords2;
- (void) createDebugWords3;

@end

@implementation WDAppDelegate

/*
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
    [[WDWordDiary sharedWordDiary] loadAll];
    
    // Override point for customization after application launch
    //[self createDebugWords];
    //[self createDebugWords2];
    //[self createDebugWords3];

    [self prepareRootViewController];
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)prepareWordDiaryAtLaunch
{
    NSDate *todayDate = [NSDate date];

    WDWord *lastCreatedWord = [[WDWordDiary sharedWordDiary] findLastCreatedWord];
    if (lastCreatedWord != nil) {
        if (![lastCreatedWord isTodayWord]) {
            if ([lastCreatedWord isEmpty]) {
                lastCreatedWord.timeInterval = [todayDate timeIntervalSince1970];
                lastCreatedWord.word = @"";
            } else {
                lastCreatedWord = nil;
            }
        }
    }
    
    if (nil == lastCreatedWord) {
        lastCreatedWord = [[WDWordDiary sharedWordDiary] createWord:@"" inTimeInterval:[todayDate timeIntervalSince1970]];
    }
}

- (void)prepareRootViewController
{
    // Defaults del registration  domain
    NSDictionary *defaults = @{@"HELP_SCREEN_HAVE_LAUCH_AT_INIT": [NSNumber numberWithBool:NO],
                               @"SPACE_TIP_SHOWED": [NSNumber numberWithBool:NO],
                               @"FIRST_BACKGROUND_SETTING": [NSNumber numberWithBool:YES]};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  
    WDWordScreenViewController *controller = [[WDWordScreenViewController alloc] init];
    self.window.rootViewController = controller;
}

- (void)createDebugWords
{
    NSArray *words = [NSArray arrayWithObjects:@"Triste", @"Aburrido", @"Vacaciones", @"Exámen", @"Papás", @"Lluvia", @"Catarro", @"Feliz", nil];
    NSArray *timeIntervalSince1970 = [NSArray arrayWithObjects:[NSNumber numberWithDouble:31104000 * 1],
                                                               [NSNumber numberWithDouble:31104000 * 1],
                                                               [NSNumber numberWithDouble:31104000 * 5],
                                                               [NSNumber numberWithDouble:31104000 * 5],
                                                               [NSNumber numberWithDouble:31104000 * 8],
                                                               [NSNumber numberWithDouble:31104000 * 9],
                                                               [NSNumber numberWithDouble:31104000 * 10],
                                                               [NSNumber numberWithDouble:31104000 * 1],
                                                               nil];
    for (NSUInteger index = 0; index < words.count; ++index) {
        NSString *wordIt = [words objectAtIndex:index];
        NSTimeInterval timeInterval = ((NSNumber *)[timeIntervalSince1970 objectAtIndex:index]).doubleValue;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        WDWord *word = [[WDWordDiary sharedWordDiary] createWord:wordIt inTimeInterval:date.timeIntervalSince1970];
        word.palette = [[WDWordDiary sharedWordDiary].palettes objectAtIndex:rand() % [WDWordDiary sharedWordDiary].palettes.count];
        word.style = [[WDWordDiary sharedWordDiary].styles objectAtIndex:rand() % [WDWordDiary sharedWordDiary].styles.count];
  
        [[WDWordDiary sharedWordDiary] saveAll];
    }
}

- (void)createDebugWords2
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    
    NSArray *words = [NSArray arrayWithObjects:@"Triste", @"Aburrido", @"Vacaciones", @"Exámen", @"Papás", @"Lluvia", @"Catarro", @"Feliz", nil];
    for (NSUInteger index = 0; index < words.count; ++index) {
        dateComponents.day = dateComponents.day - (index + 1);
        NSString *wordIt = [words objectAtIndex:index];
        NSTimeInterval timeInterval = [calendar dateFromComponents:dateComponents].timeIntervalSince1970;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        WDWord *word = [[WDWordDiary sharedWordDiary] createWord:wordIt inTimeInterval:date.timeIntervalSince1970];
        word.style = [[WDWordDiary sharedWordDiary].styles objectAtIndex:rand() % [WDWordDiary sharedWordDiary].styles.count];
        
        [[WDWordDiary sharedWordDiary] saveAll];
    }
}

- (void)createDebugWords3
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];    
    for (dateComponents.year = 2009; dateComponents.year < 2013; dateComponents.year = dateComponents.year + 1) {
        for (dateComponents.month = 1; dateComponents.month < 13; dateComponents.month = dateComponents.month + 1) {
            for (dateComponents.day = 1; dateComponents.day < 29; dateComponents.day = dateComponents.day + 1) {
                NSTimeInterval timeInterval = [calendar dateFromComponents:dateComponents].timeIntervalSince1970;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
                WDWord *word = [[WDWordDiary sharedWordDiary] createWord:@"PalabraLargaPuesVaya" inTimeInterval:date.timeIntervalSince1970];
                word.style = [[WDWordDiary sharedWordDiary].styles objectAtIndex:rand() % [WDWordDiary sharedWordDiary].styles.count];
            }
        }
    }
    
    [[WDWordDiary sharedWordDiary] saveAll];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[WDWordDiary sharedWordDiary] saveAll];
}

/*
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Word_Diary" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Word_Diary.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
 
         //Replace this implementation with code to handle the error appropriately.
         
         //abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         //Typical reasons for an error here include:
         // * The persistent store is not accessible;
         // * The schema for the persistent store is incompatible with current managed object model.
         //Check the error message to determine what the actual problem was.
         
         
         //If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         //If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         // * Simply deleting the existing store:
         //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         // * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         //@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         //Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         
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

 */
@end
