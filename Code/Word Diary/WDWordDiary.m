//
//  WDWordCalendar.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordDiary.h"
#import "WDWord.h"
#import "WDFont.h"
#import "WDBackgroundDefs.h"

@interface WDWordDiary()

- (void)configureModelAndContextOfDB;
- (NSURL *)storeFileURLWithPath;

- (NSArray *) fetchAllEntitiesOfType:(NSString *)entity;
- (void)      prepareFonts;
- (void)      prepareWords;

- (void)      addObserverToWord:(WDWord *)word;

- (void)      sortWords;

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

- (void)prepareFonts
{
    NSArray *result = [self fetchAllEntitiesOfType:@"Font"];
    
    if (result.count > 0) {
        fonts_ = [NSArray arrayWithArray:result];
    } else {
        NSMutableArray *fontInstances = [[NSMutableArray alloc] init];
        
        NSArray *fontFamilies = [NSArray arrayWithObjects:@"AcademyEngravedLetPlain",
                                 @"AmericanTypewriter",
                                 @"AppleColorEmoji",
                                 @"ArialHebrew",
                                 @"Avenir-Book",
                                 @"AvenirNext-UltraLight",
                                 @"Baskerville",
                                 @"BradleyHandITCTT-Bold",
                                 @"ChalkboardSE-Light",
                                 @"Chalkduster",
                                 @"Cochin",
                                 @"Courier",
                                 @"CourierNewPSMT",
                                 @"Didot",
                                 @"Futura-CondensedMedium",
                                 @"Georgia",
                                 @"GillSans",
                                 @"GurmukhiMN",
                                 @"Helvetica",
                                 @"HoeflerText-Regular",
                                 @"MarkerFelt-Thin",
                                 @"Noteworthy-Light",
                                 @"Palatino-Roman",
                                 @"Papyrus",
                                 @"PartyLetPlain",
                                 @"SnellRoundhand",
                                 @"TimesNewRomanPSMT",
                                 @"TrebuchetMS",
                                 @"Zapfino",
                                 nil];
        for (NSString *fontFamily in fontFamilies) {
            WDFont *font = [NSEntityDescription insertNewObjectForEntityForName:@"Font" inManagedObjectContext:self.context];
            font.family = fontFamily;
            [fontInstances addObject:font];
        }
        
        fonts_ = [NSArray arrayWithArray:fontInstances];
        
        [self saveAll];
    }
    
    fonts_ = [fonts_ sortedArrayUsingSelector:@selector(compare:)];
}

- (void)prepareWords
{
    NSArray *result = [self fetchAllEntitiesOfType:@"Word"];
    
    words_ = result.count > 0 ? [NSMutableArray arrayWithArray:result] : [NSMutableArray array];
    [self cutWordsArrayAtPresentDay];
    [self sortWords];
    
    for (WDWord *word in words_) {
        [self addObserverToWord:word];
    }
}

#pragma mark - Actions

- (void)cutWordsArrayAtPresentDay
{
    NSTimeInterval actualTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.timeInterval <= %f", actualTimeInterval];
    words_ = [NSMutableArray arrayWithArray:[words_ filteredArrayUsingPredicate:predicate]];
}

- (WDWord *)createWord:(NSString *)word inTimeInterval:(double)timeInterval
{
    WDWord *wordObject = [NSEntityDescription insertNewObjectForEntityForName:@"Word" inManagedObjectContext:self.context];
    
    wordObject.word = word;
    wordObject.timeInterval = timeInterval;
    wordObject.font = [self defaultFont];
    wordObject.backgroundCategory = rand() % 12;

    [words_ addObject:wordObject];
    [self sortWords];
    
    [self addObserverToWord:wordObject];
    
    [self saveAll];
    
    return wordObject;
}

- (void)removeWord:(WDWord *)word
{
    [word removeObserver:self forKeyPath:@"word"];
    [word removeObserver:self forKeyPath:@"timeInterval"];
    [word removeObserver:self forKeyPath:@"backgroundCategory"];
    [word removeObserver:self forKeyPath:@"font"];
    
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
    WDWord *result = [self findLastCreatedWord];
    if (result && ![result isTodayWord]) {
        result = nil;
    }
    
    return result;
}

- (WDWord *)findLastCreatedWord
{
    WDWord *result = nil;
    if (self.words.count > 0) {
        result = [self.words objectAtIndex:0];
    }

    return result;
}

- (NSUInteger)findIndexPositionForWord:(WDWord *)word
{
    NSUInteger retIndex = NSNotFound;
    
    retIndex = self.words.count - [self.words indexOfObject:word];
    
    return retIndex;
}

- (WDWord *)findNextWordOf:(WDWord *)word
{
    NSAssert(self.words.count > 0, @"Deberia de haber al menos una palabra");
    
    WDWord *retWord = nil;
    NSUInteger index = [self.words indexOfObject:word];
    if (index != NSNotFound && index != self.words.count - 1) {
        retWord = [self.words objectAtIndex:index + 1];
    }
    
    return retWord;
}

- (WDWord *)findPreviousWordOf:(WDWord *)word
{
    NSAssert(self.words.count > 0, @"Deberia de haber al menos una palabra");
    
    WDWord *retWord = nil;
    NSUInteger index = [self.words indexOfObject:word];
    if (index != NSNotFound && index != 0) {
        retWord = [self.words objectAtIndex:index - 1];
    }
    
    return retWord;
}

#pragma mark - Auxiliary

- (void)addObserverToWord:(WDWord *)word
{
    [word addObserver:self forKeyPath:@"word" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"timeInterval" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"font" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"backgroundCategory" options:0 context:NULL];
}

- (void)sortWords
{
    // Se ordena de forma descendente, de palabras mas nueva a mas antigua
    NSArray *sortedWords = [words_ sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WDWord *wordObj1 = obj1;
        WDWord *wordObj2 = obj2;
        return [wordObj2 compare:wordObj1];
    }];
    words_ = [NSMutableArray arrayWithArray:sortedWords];
}

#pragma mark - Default

- (WDColor *)defaultColor
{
    return [self.colors objectAtIndex:0];
}

- (WDFont *)defaultFont
{
    /*
    NSUInteger indexOfObject = [self.fonts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        WDFont *font = obj;
        *stop = [font.family compare:@"SnellRoundhand"] == NSOrderedSame;
        return *stop;
    }];
    
    NSAssert(indexOfObject != NSNotFound, @"Object index of default font not found");
    */
    return [self.fonts objectAtIndex:0];
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self saveAll];
    
    if ([keyPath compare:@"timeInterval"] == NSOrderedSame) {
      //  [self sortWords];
    }
}

@end
