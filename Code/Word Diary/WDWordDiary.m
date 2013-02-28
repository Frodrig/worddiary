//
//  WDWordCalendar.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordDiary.h"
#import "WDWord.h"
#import "WDColor.h"
#import "WDFont.h"

@interface WDWordDiary()

- (void)configureModelAndContextOfDB;
- (NSURL *)storeFileURLWithPath;

- (NSArray *) fetchAllEntitiesOfType:(NSString *)entity;
- (void)      prepareColors;
- (void)      prepareFonts;
- (void)      prepareWords;

- (void)      addObserverToWord:(WDWord *)word;

@end

@implementation WDWordDiary

#pragma mark - Synthesize

@synthesize model   = model_;
@synthesize context = context_;
@synthesize words   = words_;
@synthesize colors  = colors_;
@synthesize fonts   = fonts_;

#pragma mark - Singleton

+ (WDWordDiary *)sharedWordDiary
{
    static WDWordDiary *wordDiary = nil;
    if (nil == wordDiary) {
        wordDiary = [[super allocWithZone:nil] init];
    }
    
    return wordDiary;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedWordDiary];
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        [self configureModelAndContextOfDB];
        [self prepareFonts];
        [self prepareColors];
        [self prepareWords];
    }
    
    return self;
}

- (void)configureModelAndContextOfDB
{
    model_ = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStore = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model_];
    
    NSError *error;
    if (![persistentStore addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeFileURLWithPath] options:nil error:&error]) {
        [NSException raise:NSLocalizedString(@"TAG_OPENDB_FAILED", @"") format:NSLocalizedString(@"TAG_OPENDBFAILED_REASON", @""), [error localizedDescription]];
    }
    
    context_ = [[NSManagedObjectContext alloc] init];
    context_.persistentStoreCoordinator = persistentStore;
    context_.undoManager = nil;
}

- (NSURL *)storeFileURLWithPath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    NSURL* retURL = [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent:@"worddiary.data"]];
    
    return retURL;
}

- (NSArray *)fetchAllEntitiesOfType:(NSString *)entity
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [self.model.entitiesByName objectForKey:entity];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:NSLocalizedString(@"TAG_FETCHFAILED", @"") format:NSLocalizedString(@"TAG_FETCHFAILED_REASON", @"")];
    }
    
    return result;
}

- (void)prepareColors
{
    NSArray *result = [self fetchAllEntitiesOfType:@"Color"];
    
    if (result.count > 0) {
        colors_ = [NSArray arrayWithArray:result];
    } else {
        NSMutableArray *colorInstances = [[NSMutableArray alloc] init];
        NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor],
                                                    [UIColor greenColor],
                                                    [UIColor blueColor],
                                                    [UIColor colorWithRed:0 green:0 blue:0 alpha:1],
                                                    [UIColor colorWithRed:1 green:1 blue:1 alpha:1], nil];
        for (UIColor *colorByComponents in colors) {
            CGFloat redComponent;
            CGFloat greenComponent;
            CGFloat blueComponent;
            CGFloat alphaComponent;
            [colorByComponents getRed:&redComponent green:&greenComponent blue:&blueComponent alpha:&alphaComponent];
           
            WDColor *color = [NSEntityDescription insertNewObjectForEntityForName:@"Color" inManagedObjectContext:self.context];
            color.red = redComponent;
            color.green = greenComponent;
            color.blue = blueComponent;
            color.alpha = alphaComponent;
            
            [colorInstances addObject:color];
        }
        
        colors_ = [NSArray arrayWithArray:colorInstances];
        
        [self saveAll];
    }
}

- (void)prepareFonts
{
    NSArray *result = [self fetchAllEntitiesOfType:@"Font"];
    
    if (result.count > 0) {
        fonts_ = [NSArray arrayWithArray:result];
    } else {
        NSMutableArray *fontInstances = [[NSMutableArray alloc] init];
        
        NSArray *fontFamilies = [NSArray arrayWithObjects:@"AppleColorEmoji", @"Baskerville", @"BrandleyHandITCTT-Bold", @"Zapfino", @"HelveticaNue", nil];
        for (NSString *fontFamily in fontFamilies) {
            WDFont *font = [NSEntityDescription insertNewObjectForEntityForName:@"Font" inManagedObjectContext:self.context];
            font.family = fontFamily;
            [fontInstances addObject:font];
        }
        
        fonts_ = [NSArray arrayWithArray:fontInstances];
        
        [self saveAll];
    }
}

- (void)prepareWords
{
    NSArray *result = [self fetchAllEntitiesOfType:@"Word"];
    
    words_ = result.count > 0 ? [NSMutableArray arrayWithArray:result] : [NSMutableArray array];
    [words_ sortedArrayUsingSelector:@selector(compare:)];
    
    for (WDWord *word in words_) {
        [self addObserverToWord:word];
    }
}

#pragma mark - Actions

- (WDWord *)createWord:(NSString *)word inTimeInterval:(double)timeInterval
{
    WDWord *wordObject = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.context];
    
    wordObject.word = word;
    wordObject.timeInterval = timeInterval;
    wordObject.font = [self defaultFont];
    wordObject.wordColor = [self defaultColor];
    wordObject.backgroundColor = [self defaultColor];
    
    [words_ addObject:wordObject];
    [words_ sortedArrayUsingSelector:@selector(compare:)];
    
    [self addObserverToWord:wordObject];
    
    [self saveAll];
    
    return wordObject;
}

- (void)removeWord:(WDWord *)word
{
    [word removeObserver:self forKeyPath:@"word"];
    [word removeObserver:self forKeyPath:@"timeInterval"];
    [word removeObserver:self forKeyPath:@"wordColor"];
    [word removeObserver:self forKeyPath:@"backgroundColor"];
    
    [self.context refreshObject:word.backgroundColor mergeChanges:NO];
    [self.context refreshObject:word.wordColor mergeChanges:NO];
    [self.context refreshObject:word.font mergeChanges:NO];
    [self.context refreshObject:word mergeChanges:NO];
    
    [words_ removeObject:word];
    [self.context deleteObject:word];
    
    [self saveAll];
}

- (void)saveAll
{
    NSError *error;
    if (/*[self.context hasChanges] &&*/ ![self.context save:&error]) {
        [NSException raise:NSLocalizedString(@"TAG_ERRORSAVING", @"") format:NSLocalizedString(@"TAG_ERRORSAVING_REASON", @"")];
    }
}

#pragma mark - Find

- (WDWord *)findTodayWord
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayDateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    
    WDWord *result = nil;
    for (WDWord *word in self.words) {
        if ([todayDateComponents.date compare:word.dateComponents.date] == NSOrderedSame) {
            result = word;
            break;
        }
    }
    
    return result;
}

- (WDWord *)findLastCreatedWord
{
    WDWord *result = nil;
    if (self.words.count > 0) {
        result = [self.words objectAtIndex:self.words.count - 1];
    }

    return result;
}

#pragma mark - Auxiliary

- (void) addObserverToWord:(WDWord *)word
{
    [word addObserver:self forKeyPath:@"word" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"timeInterval" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"wordColor" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"backgroundColor" options:0 context:NULL];
}


#pragma mark - Default

- (WDColor *)defaultColor
{
    UIColor *defaultColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    NSUInteger indexOfObject = [self.colors indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        WDColor *color = obj;
        *stop = CGColorEqualToColor(color.colorObject.CGColor, defaultColor.CGColor);
        return *stop;
    }];
    
    NSAssert(indexOfObject != NSNotFound, @"Object index of default color not found");
    return [self.colors objectAtIndex:indexOfObject];
}

- (WDFont *)defaultFont
{
    NSUInteger indexOfObject = [self.fonts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        WDFont *font = obj;
        *stop = [font.family compare:@"Baskerville"] == NSOrderedSame;
        return *stop;
    }];
    
    NSAssert(indexOfObject != NSNotFound, @"Object index of default font not found");
    return [self.fonts objectAtIndex:indexOfObject];
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self saveAll];
    
    if ([keyPath compare:@"timeInterval"] == NSOrderedSame) {
        [words_ sortedArrayUsingSelector:@selector(compare:)];
    }
}

@end
