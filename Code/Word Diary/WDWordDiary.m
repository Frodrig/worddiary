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
#import "WDEmotion.h"
#import "WDBackgroundDefs.h"

@interface WDWordDiary()

- (void)configureModelAndContextOfDB;
- (NSURL *)storeFileURLWithPath;

- (NSArray *) fetchAllEntitiesOfType:(NSString *)entity;

- (void)      prepareStyles;
- (void)      addPalette:(NSString *)idName backgroundColor:(NSString *)backColor wordColor:(NSString *)wordColor andAccesoriesColor:(NSString *)accessoriesColor;       
- (void)      preparePalettes;
- (void)      prepareEmotions;
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
@synthesize emotions = emotions_;
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
        [self prepareEmotions];
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

- (void)addPalette:(NSString *)idName backgroundColor:(NSString *)backColor wordColor:(NSString *)wordColor andAccesoriesColor:(NSString *)accessoriesColor
{
    WDPalette *palette = [NSEntityDescription insertNewObjectForEntityForName:@"WDPalette" inManagedObjectContext:self.context];
    palette.idName = idName;
    palette.backgroundColor = backColor;
    palette.wordColor = wordColor;
    palette.accessoriesColor = accessoriesColor;
    
    palettes_ = palettes_ == nil ? [NSArray arrayWithObject:palette] : [palettes_ arrayByAddingObject:palette];
}

- (void)preparePalettes
{
    NSArray *result = [self fetchAllEntitiesOfType:@"WDPalette"];
    if (result.count > 0) {
        palettes_ = result;
    } else {
        [self addPalette:@"215" backgroundColor:@"0xB8C3D9" wordColor:@"0x263940" andAccesoriesColor:@"0x263940"];
        [self addPalette:@"214" backgroundColor:@"0xB8E3D9" wordColor:@"0x263A40" andAccesoriesColor:@"0x2A3940"];
        [self addPalette:@"213" backgroundColor:@"0xB8F3D9" wordColor:@"0x263C40" andAccesoriesColor:@"0x2B3940"];
        [self addPalette:@"212" backgroundColor:@"0xB853D9" wordColor:@"0x263F40" andAccesoriesColor:@"0x2C3940"];
        [self addPalette:@"211" backgroundColor:@"0xB823D9" wordColor:@"0x263440" andAccesoriesColor:@"0x2E3940"];
        [self addPalette:@"210" backgroundColor:@"0xB8A3D9" wordColor:@"0x263740" andAccesoriesColor:@"0x223940"];
        [self addPalette:@"209" backgroundColor:@"0xB8B3D9" wordColor:@"0x263E40" andAccesoriesColor:@"0x213940"];

        // ToDo: Por ahora una unica paleta para todas las emociones
        
        [self saveAll];
    }
}
                                          
- (void)prepareEmotions
{
    NSArray *result = [self fetchAllEntitiesOfType:@"WDEmotion"];
    if (result.count > 0) {
        emotions_ = result;
    } else {
        NSArray *emotionsNames = [NSArray arrayWithObjects:@"TAG_EMOTION_NAME_NEUTRAL",
                                                           @"TAG_EMOTION_NAME_LOVE",
                                                           @"TAG_EMOTION_NAME_FEAR",
                                                           @"TAG_EMOTION_NAME_JOY",
                                                           @"TAG_EMOTION_NAME_SADNESS",
                                                           @"TAG_EMOTION_NAME_SURPRISE",
                                                           @"TAG_EMOTION_NAME_DISGUST",
                                                      nil];
        NSMutableArray *emotionInstances = [NSMutableArray arrayWithCapacity:emotionsNames.count];
        
        NSInteger paletteIndex = 0;
        for (NSString *emotionName in emotionsNames) {
            WDEmotion *emotion = [NSEntityDescription insertNewObjectForEntityForName:@"WDEmotion" inManagedObjectContext:self.context];
            emotion.name = emotionName;
            // ToDo: Por ahora todas las emociones con las mismas paletas
            WDPalette *paletteOfEmotion = [palettes_ objectAtIndex:paletteIndex++];
            [emotion addPaletteObject:paletteOfEmotion];

            [emotionInstances addObject:emotion];
        }
        
        [self saveAll];
        
        emotions_ = emotionInstances;
    }
    
    result = [result sortedArrayUsingSelector:@selector(compare:)];
  }

- (void)prepareWords
{
    NSArray *result = [self fetchAllEntitiesOfType:@"WDWord"];
    
    words_ = result.count > 0 ? [NSMutableArray arrayWithArray:result] : [NSMutableArray array];
    [self cutWordsArrayAtPresentDay];
    [self sortWords];
    
    for (WDWord *word in words_) {
        [self addObserverToWord:word];
        NSLog(@"Loading word %@", word.paletteIdNameOfEmotion);
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
    wordObject.emotion = [self defaultEmotion];
    // ToDo: Este valor tiene que venir de un parametro de la funcion
    WDPalette *paletteOfEmotion = [wordObject.emotion.palette anyObject];
    wordObject.paletteIdNameOfEmotion = paletteOfEmotion.idName;
    
    NSLog(@"createWord emotion name %@", wordObject.emotion.name);

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
    //[word removeObserver:self forKeyPath:@"emotion"];
    
    [self.context refreshObject:word.emotion mergeChanges:NO];
    [self.context refreshObject:word.style mergeChanges:NO];
    [self.context refreshObject:word mergeChanges:NO];
    
    [words_ removeObject:word];
    [self.context deleteObject:word];
    
    [self saveAll];
}

- (void)changeToEmotionIndex:(NSUInteger)emotionIdx inWord:(WDWord *)word
{
    WDEmotion *emotion = [self.emotions objectAtIndex:emotionIdx];
    [self changeToEmotion:emotion inWord:word];
}

- (void)changeToEmotion:(WDEmotion *)emotion inWord:(WDWord *)word
{
    NSAssert(emotion, @"Invalid emotion");
    
    word.emotion = emotion;
    WDPalette *palette = [[emotion.palette allObjects] objectAtIndex:0];
    word.paletteIdNameOfEmotion = palette.idName;
    
    [self saveAll];
}

- (void)saveAll
{
    NSError *error;
    if (/*[self.context hasChanges] &&*/ ![self.context save:&error]) {
        [NSException raise:NSLocalizedString(@"TAG_ERRORSAVING", @"") format:NSLocalizedString(@"TAG_ERRORSAVING_REASON", @"")];
    }
    NSLog(@"SAVE");
    for (WDWord *word in self.words) {
        NSLog(@"idname %@", word.paletteIdNameOfEmotion);
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


#pragma mark - Auxiliary

- (void)addObserverToWord:(WDWord *)word
{
    [word addObserver:self forKeyPath:@"word" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"timeInterval" options:0 context:NULL];
    [word addObserver:self forKeyPath:@"style" options:0 context:NULL];
    // Cambiar una emocion es mas complejo que cambiar la variable. Hay que usar un metodo especifico y es desde ahi desde donde hacemos el save
    //[word addObserver:self forKeyPath:@"emotion" options:0 context:NULL];
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

- (WDEmotion *)defaultEmotion
{
    return [self.emotions objectAtIndex:0];
}

- (WDStyle *)defaultStyle
{
    /*
    NSUInteger indexOfObject = [self.fonts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        WDFont *font = obj;
        *stop = [font.family compare:@"SnellRoundhand"] == NSOrderedSame;
        return *stop;
    }];
    
    NSAssert(indexOfObject != NSNotFound, @"Object index of default font not found");
    */
    return [self.styles objectAtIndex:0];
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
