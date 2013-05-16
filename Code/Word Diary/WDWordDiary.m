//
//  WDWordCalendar.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordDiary.h"
#import "WDWord.h"
#import "WDStyle.h"
#import "WDPalette.h"
#import "WDUtils.h"

@interface WDWordDiary()

- (void)      configureModelAndContextOfDB;
- (NSURL *)   storeFileURLWithPath;

- (NSArray *) fetchAllEntitiesOfType:(NSString *)entity;

- (void)      prepareStyles;
- (void)      addPalette:(NSString *)idName lightBackgroundColor:(NSString *)lBackgroundColor andWordColor:(NSString *)wColor;
- (void)      preparePalettes;
- (void)      prepareWords;

- (void)      addObserverToWord:(WDWord *)word;

- (void)      sortWords;

@end

@implementation WDWordDiary

#pragma mark - Synthesize

@synthesize model    = model_;
@synthesize context  = context_;
@synthesize words    = words_;
@synthesize colors   = colors_;
@synthesize styles   = styles_;
@synthesize palettes = palettes_;

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
        [self preparePalettes];
        [self prepareStyles];
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

- (void)prepareStyles
{
    NSArray *result = [self fetchAllEntitiesOfType:@"WDStyle"];
    
    if (result.count > 0) {
        styles_ = result;
    } else {        
        NSArray *fontFamilies = [NSArray arrayWithObjects:
                                 @"Baskerville",
                                 @"Zapfino",
                                 @"PartyLetPlain",
                                 @"SnellRoundhand",
                                 nil];
        NSMutableArray *styleInstances = [NSMutableArray arrayWithCapacity:fontFamilies.count];
                                          
        for (NSString *fontFamily in fontFamilies) {
            WDStyle *style = [NSEntityDescription insertNewObjectForEntityForName:@"WDStyle" inManagedObjectContext:self.context];
            style.familyFont = fontFamily;
            
            [styleInstances addObject:style];
        }
        
        styles_ = [NSArray arrayWithArray:styleInstances];
        
        [self saveAll];
    }
    
    styles_ = [styles_ sortedArrayUsingSelector:@selector(compare:)];
}

- (void)addPalette:(NSString *)idName lightBackgroundColor:(NSString *)lBackgroundColor andWordColor:(NSString *)wColor;
{
    WDPalette *palette = [NSEntityDescription insertNewObjectForEntityForName:@"WDPalette" inManagedObjectContext:self.context];
    palette.idName = idName;
    palette.lightBackground = lBackgroundColor;
    palette.wordColor = wColor;
    
    palettes_ = palettes_ == nil ? [NSArray arrayWithObject:palette] : [palettes_ arrayByAddingObject:palette];
}

- (void)preparePalettes
{
    NSArray *result = [self fetchAllEntitiesOfType:@"WDPalette"];
    if (result.count > 0) {
        palettes_ = [result sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            WDPalette *palette1 = obj1;
            WDPalette *palette2 = obj2;
            NSNumber *palette1Id = [NSNumber numberWithInteger:[palette1.idName integerValue]];
            NSNumber *palette2Id = [NSNumber numberWithInteger:[palette2.idName integerValue]];
            return [palette1Id compare:palette2Id];
        }];
    } else {
        /*
        NSArray *lighPalettes = [WDUtils makeColorGradientWithParameters:@{ @"rFrecuency":@0.366F, @"gFrecuency":@0.466F, @"bFrecuency":@0.566F,
                                 @"rPhase":@0.0F, @"gPhase":@2.0F, @"rPhase":@4.0F,
                                 @"center":@220.0F, @"amplitude":@35.0F, @"loopLenght":@1440.0F}];
        */
        NSArray *palette = [WDUtils makeColorGradientWithHSL];
        for (NSUInteger paletteIndex = 0; paletteIndex < palette.count; ++paletteIndex) {
            NSString *paletteId = [NSString stringWithFormat:@"%d", paletteIndex];
            NSString *lightBackgroundColorString = [WDUtils convertColorToString:[palette objectAtIndex:paletteIndex]];
            NSString *wordColorString = [WDUtils convertColorToString:[UIColor colorWithRed:46.0 green:46.0 blue:51.0 alpha:1.0]];//[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
            
            [self addPalette:paletteId lightBackgroundColor:lightBackgroundColorString andWordColor:wordColorString];
        }
        
        // ToDo: Por ahora una unica paleta para todas las emociones
        [self saveAll];
    }
}

- (void)prepareWords
{
    NSArray *result = [self fetchAllEntitiesOfType:@"WDWord"];
    
    words_ = result.count > 0 ? [NSMutableArray arrayWithArray:result] : [NSMutableArray array];
    [self cutWordsArrayAtPresentDay];
    [self sortWords];
    
    for (WDWord *word in words_) {
        [self addObserverToWord:word];
    }
}

#pragma mark - Actions

- (BOOL)cutWordsArrayAtPresentDay
{
    const NSUInteger previousWordCount = words_.count;
    
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    todayDateComponents.hour = 23;
    todayDateComponents.minute = 59;
    todayDateComponents.second = 59;
    NSTimeInterval todayLimitTimeInterval = [[NSCalendar currentCalendar] dateFromComponents:todayDateComponents].timeIntervalSince1970;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.timeInterval <= %f", todayLimitTimeInterval];
    
    words_ = [NSMutableArray arrayWithArray:[words_ filteredArrayUsingPredicate:predicate]];
    
    return words_.count != previousWordCount;
}

- (WDWord *)createWord:(NSString *)word inTimeInterval:(double)timeInterval
{
    WDWord *wordObject = [NSEntityDescription insertNewObjectForEntityForName:@"WDWord" inManagedObjectContext:self.context];
    
    wordObject.word = word;
    wordObject.timeInterval = timeInterval;
    wordObject.style = [self defaultStyle];
    wordObject.palette = [self randomPalette];
    
    [words_ addObject:wordObject];
    [self sortWords];
    
    [self addObserverToWord:wordObject];
    
    [self saveAll];
    
    return wordObject;
}

- (NSArray *)findAllDaysIndexWithoutWord
{
    NSMutableArray *indexWordToRemove = [[NSMutableArray alloc] init];
    for (NSUInteger indexIt = 0; indexIt < self.words.count; indexIt++) {
        WDWord *word = [self.words objectAtIndex:indexIt];
        if (![word isTodayWord]) {
            if (word.word.length == 0) {
                [indexWordToRemove addObject:[NSNumber numberWithUnsignedInteger:indexIt]];
            }
        }
    }
    
    return [NSArray arrayWithArray:indexWordToRemove];
}


- (NSArray *)removeAllDaysWithoutWord
{
    NSArray *indexWordToRemove = [self findAllDaysIndexWithoutWord];
    for (NSNumber *indexWordIt in indexWordToRemove) {
        WDWord *wordToRemove = [self.words objectAtIndex:indexWordIt.unsignedIntegerValue];
        [self removeWord:wordToRemove];
    }
    
    [self saveAll];
    
    return indexWordToRemove;
}

- (void)removeWord:(WDWord *)word
{
    [word removeObserver:self forKeyPath:@"word"];
    [word removeObserver:self forKeyPath:@"timeInterval"];
    //[word removeObserver:self forKeyPath:@"style"];
    //[word removeObserver:self forKeyPath:@"palette"];
    
    [self.context refreshObject:word.style mergeChanges:NO];
    [self.context refreshObject:word.palette mergeChanges:NO];
    [self.context refreshObject:word mergeChanges:NO];
    
    [words_ removeObject:word];
    [self.context deleteObject:word];
    
    [self saveAll];
}

- (void)removeWordAtIndexPosition:(NSUInteger)wordIndexPosition
{
    WDWord *word = [self.words objectAtIndex:wordIndexPosition];
    [self removeWord:word];
}

- (void)saveAll
{
    NSError *error;
    if (/*[self.context hasChanges] &&*/ ![self.context save:&error]) {
        [NSException raise:NSLocalizedString(@"TAG_ERRORSAVING", @"") format:NSLocalizedString(@"TAG_ERRORSAVING_REASON", @"")];
    }
}

#pragma mark - Find

- (NSUInteger)findNumberOfWordsInYear:(NSUInteger)year
{
    return [self findNumberOfWordsInMonth:0 ofYear:year];
}

- (NSUInteger)findNumberOfWordsInMonth:(NSUInteger)month ofYear:(NSUInteger)year
{
    NSUInteger retNumberOfWords = 0;
    for (WDWord *word in self.words) {
        BOOL updateCounter = NO;
        if (month > 0) {
            updateCounter = word.dateComponents.month == month && word.dateComponents.year == year;
        } else {
            updateCounter = word.dateComponents.year == year;
        }
        if (updateCounter) {
            updateCounter = word.word.length > 0;
        }
        retNumberOfWords += updateCounter ? 1 : 0;
    }
    
    return retNumberOfWords;
}

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
    
    retIndex = self.words.count - [self.words indexOfObject:word] - 1;
    
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

- (WDPalette *)findPaletteWithIdName:(NSString *)idName
{
    WDPalette *retPalette = nil;
    for (WDPalette *palette in self.palettes) {
        if ([palette.idName compare:idName] == NSOrderedSame) {
            retPalette = palette;
            break;
        }
    }
    return retPalette;
}

- (WDPalette *)findPrevPaletteOfPalette:(WDPalette *)palette
{
    WDPalette *retPalette = nil;
    if (nil == palette) {
        retPalette = [self.palettes objectAtIndex:self.palettes.count - 1];
    } else {
        NSUInteger indexOfPalette = [self.palettes indexOfObject:palette];
        if (indexOfPalette == 0) {
            retPalette = [self findPrevPaletteOfPalette:nil];
        } else {
            retPalette = [self.palettes objectAtIndex:indexOfPalette - 1];
        }
    }
    
    return retPalette;
}

- (WDPalette *)findNextPaletteOfPalette:(WDPalette *)palette
{
    WDPalette *retPalette = nil;
    if (nil == palette) {
        retPalette = [self.palettes objectAtIndex:0];
    } else {
        NSUInteger indexOfPalette = [self.palettes indexOfObject:palette];
        if (indexOfPalette == self.palettes.count - 1) {
            retPalette = [self findNextPaletteOfPalette:nil];
        } else {
            retPalette = [self.palettes objectAtIndex:indexOfPalette + 1];
        }
    }
    
    return retPalette;
}

- (NSArray *)makeGradientColorPaletteOfWord:(WDWord *)word
{
    WDPalette *prevPalette = [self findPrevPaletteOfPalette:word.palette];
    WDPalette *nextPalette = [self findNextPaletteOfPalette:word.palette];
    WDPalette *prevprevPalette = [self findPrevPaletteOfPalette:prevPalette];
    WDPalette *nextnextPalette = [self findNextPaletteOfPalette:nextPalette];
    WDPalette *prevprevprevPalette = [self findPrevPaletteOfPalette:prevprevPalette];
    WDPalette *nextnextnextPalette = [self findNextPaletteOfPalette:nextnextPalette];
    //WDPalette *prevprevprevprevPalette = [self findPrevPaletteOfPalette:prevprevprevPalette];
    //WDPalette *nextnextnextnextPalette = [self findNextPaletteOfPalette:nextnextnextPalette];
    
    NSArray *gradientColorArray = [[NSArray alloc]
                                   initWithObjects:
                                   //[prevprevprevprevPalette makeLightBackgroundColorObject],
                                   [prevprevprevPalette makeLightBackgroundColorObject],
                                   [prevprevPalette makeLightBackgroundColorObject],
                                   [prevPalette makeLightBackgroundColorObject],
                                   [word.palette makeLightBackgroundColorObject],
                                   [nextPalette makeLightBackgroundColorObject],
                                   [nextnextPalette makeLightBackgroundColorObject],
                                   [nextnextnextPalette makeLightBackgroundColorObject],
                                  // [nextnextnextnextPalette makeLightBackgroundColorObject],
                                   nil];
    
    return gradientColorArray;

}


- (NSArray *)makeGradientCGColorPaletteOfWord:(WDWord *)word
{
    NSArray *gradientColorPalette = [self makeGradientColorPaletteOfWord:word];
    NSMutableArray *retGradientCGColorPalette = [[NSMutableArray alloc] initWithCapacity:gradientColorPalette.count];
    for (UIColor *color in gradientColorPalette) {
        [retGradientCGColorPalette addObject:(id)color.CGColor];
    }

    return retGradientCGColorPalette;//[NSArray arrayWithArray:retGradientCGColorPalette];
}

- (NSUInteger)findIndexPositionForStyle:(WDStyle *)style
{
    NSUInteger retIndex = NSNotFound;
    for (NSUInteger indexIt = 0; self.styles.count; indexIt++) {
        WDStyle *styleIt = [self.styles objectAtIndex:indexIt];
        if (styleIt == style) {
            retIndex = indexIt;
            break;
        }
    }
    
    return retIndex;
}

- (WDWord *)findWordWithDateComponents:(NSDateComponents *)dateComponents
{
    NSUInteger indexOfWordObject = [self.words indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        WDWord *wordIt = obj;
        BOOL found = wordIt.dateComponents.year == dateComponents.year &&
                      wordIt.dateComponents.month == dateComponents.month &&
                      wordIt.dateComponents.day == dateComponents.day;
        *stop = found;
        return found;
    }];

    return indexOfWordObject != NSNotFound ? [self.words objectAtIndex:indexOfWordObject] : nil;
}

#pragma mark - Auxiliary

- (void)addObserverToWord:(WDWord *)word
{
    [word addObserver:self forKeyPath:@"word" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"timeInterval" options:0 context:NULL];
    // Por optimizacion, se deja la grabacion a salir del modo edicion para evitar que cada vez que se cambia el estilo se guarde
    //[word addObserver:self forKeyPath:@"style" options:0 context:NULL];
    // Por optimizacion, se deja la grabacion en la zona de cambio del valor cuando ha terminado de realizarse el drag
    //[word addObserver:self forKeyPath:@"palette" options:0 context:NULL];
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

- (WDStyle *)defaultStyle
{
    return [self.styles objectAtIndex:0];
}

- (WDPalette *)defaultPalette
{
    return [self.palettes objectAtIndex:0];
}

- (WDPalette *)randomPalette
{
    NSUInteger indexPalette = rand() % self.palettes.count;
    return [self.palettes objectAtIndex:indexPalette];
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // para una palabra, timeInterval y cadena asociada
    [self saveAll];
}

@end
