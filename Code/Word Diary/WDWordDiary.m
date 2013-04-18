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
#import "WDBackgroundDefs.h"
#import "WDUtils.h"

@interface WDWordDiary()

- (void)      configureModelAndContextOfDB;
- (NSURL *)   storeFileURLWithPath;

- (NSArray *) fetchAllEntitiesOfType:(NSString *)entity;

- (void)      prepareStyles;
- (void)      addPalette:(NSString *)idName lightBackgroundColor:(NSString *)lBackgroundColor darkBackgroundColor:(NSString *)dBackgroundColor wordColor:(NSString *)wColor andAccesoriesColor:(NSString *)aColor;
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
                                 @"Copperplate",
                                 @"CourierNewPSMT",
                                 @"Noteworthy-Light",
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

- (void) addPalette:(NSString *)idName lightBackgroundColor:(NSString *)lBackgroundColor darkBackgroundColor:(NSString *)dBackgroundColor wordColor:(NSString *)wColor andAccesoriesColor:(NSString *)aColor;
{
    WDPalette *palette = [NSEntityDescription insertNewObjectForEntityForName:@"WDPalette" inManagedObjectContext:self.context];
    palette.idName = idName;
    palette.lightBackground = lBackgroundColor;
    palette.darkBackground = dBackgroundColor;
    palette.wordColor = wColor;
    palette.accessoriesColor = aColor;
    
    palettes_ = palettes_ == nil ? [NSArray arrayWithObject:palette] : [palettes_ arrayByAddingObject:palette];
}

- (void)preparePalettes
{
    NSArray *result = [self fetchAllEntitiesOfType:@"WDPalette"];
    if (result.count > 0) {
        palettes_ = result;
    } else {
        NSArray *lighPalette = [WDUtils makeColorGradientWithParameters:@{ @"rFrecuency":@0.3F, @"gFrecuency":@0.3F, @"bFrecuency":@0.3F,
                                                                           @"rPhase":@0.0F, @"gPhase":@2.0F, @"rPhase":@4.0F,
                                                                           @"center":@230.0F, @"amplitude":@25.0F, @"loopLenght":@50.0F }];
        NSArray *darkPalette = [WDUtils makeColorGradientWithParameters:@{ @"rFrecuency":@0.3F, @"gFrecuency":@0.3F, @"bFrecuency":@0.3F,
                                                                           @"rPhase":@0.0F, @"gPhase":@2.0F, @"rPhase":@4.0F,
                                                                           @"center":@200.0F, @"amplitude":@55.0F, @"loopLenght":@50.0F }];
        
        for (NSUInteger paletteIndex = 0; paletteIndex < lighPalette.count; ++paletteIndex) {
            NSString *paletteId = [NSString stringWithFormat:@"%d", paletteIndex];
            NSString *lightBackgroundColorString = ((UIColor *)[lighPalette objectAtIndex:paletteIndex]).CIColor.stringRepresentation;
            NSString *darkBackgroundColorString = ((UIColor *)[darkPalette objectAtIndex:paletteIndex]).CIColor.stringRepresentation;
            NSString *wordColorString = [UIColor blackColor].CIColor.stringRepresentation;
            NSString *accesoriesColorString = [UIColor blackColor].CIColor.stringRepresentation;
            
            [self addPalette:paletteId lightBackgroundColor:lightBackgroundColorString darkBackgroundColor:darkBackgroundColorString wordColor:wordColorString andAccesoriesColor:accesoriesColorString];
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

- (void)cutWordsArrayAtPresentDay
{
    NSDate *todayDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayDateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:todayDate];
    todayDateComponents.hour = 23;
    todayDateComponents.minute = 59;
    todayDateComponents.second = 59;
    NSTimeInterval todayLimitTimeInterval = [calendar dateFromComponents:todayDateComponents].timeIntervalSince1970;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.timeInterval <= %f", todayLimitTimeInterval];
    
    words_ = [NSMutableArray arrayWithArray:[words_ filteredArrayUsingPredicate:predicate]];
}

- (WDWord *)createWord:(NSString *)word inTimeInterval:(double)timeInterval
{
    WDWord *wordObject = [NSEntityDescription insertNewObjectForEntityForName:@"WDWord" inManagedObjectContext:self.context];
    
    wordObject.word = word;
    wordObject.timeInterval = timeInterval;
    wordObject.style = [self defaultStyle];
    wordObject.palette = [self defaultPalette];
    
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
    [word removeObserver:self forKeyPath:@"style"];
    [word removeObserver:self forKeyPath:@"palette"];
    
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

- (WDPalette *) findPrevPaletteOfPalette:(WDPalette *)palette
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

- (WDPalette *) findNextPaletteOfPalette:(WDPalette *)palette
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


#pragma mark - Auxiliary

- (void)addObserverToWord:(WDWord *)word
{
    [word addObserver:self forKeyPath:@"word" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"timeInterval" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"style" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"palette" options:0 context:NULL];
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

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self saveAll];
    
    if ([keyPath compare:@"timeInterval"] == NSOrderedSame) {
      //  [self sortWords];
    }
}

@end
