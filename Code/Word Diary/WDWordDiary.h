//
//  WDWordCalendar.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWord;
@class WDStyle;
@class WDPalette;

@interface WDWordDiary : NSObject

@property (nonatomic, readonly, strong) NSManagedObjectContext *context;
@property (nonatomic, readonly, strong) NSManagedObjectModel   *model;
@property (nonatomic, readonly, strong) NSMutableArray         *words;
@property (nonatomic, strong)           NSArray                *colors;
@property (nonatomic, strong)           NSArray                *styles;
@property (nonatomic, strong)           NSArray                *palettes;
@property (nonatomic, readonly, strong) NSCalendar             *currentCalendar;

+ (WDWordDiary *) sharedWordDiary;

- (void)          loadAll;

- (NSCalendar *)  currentCalendar;

- (WDWord *)      createWord:(NSString *)word inTimeInterval:(double)timeInterval;
- (void)          removeWord:(WDWord *)word;
- (void)          removeWordAtIndexPosition:(NSUInteger)wordIndexPosition;
- (NSArray *)     removeAllDaysWithoutWord;

- (void)          saveAll;

- (WDWord *)      findTodayWord;
- (WDWord *)      findLastCreatedWord;
- (WDWord *)      findNextWordOf:(WDWord *)word;
- (WDWord *)      findPreviousWordOf:(WDWord *)word;
- (WDWord *)      findWordWithDateComponents:(NSDateComponents *)dateComponents;
- (NSUInteger)    findIndexPositionForWord:(WDWord *)word;
- (NSArray *)     findAllDaysIndexWithoutWord;

- (NSUInteger)    findNumberOfWordsInYear:(NSUInteger)year;
- (NSUInteger)    findNumberOfWordsInMonth:(NSUInteger)month ofYear:(NSUInteger)year;

- (WDPalette *)   findNextPaletteOfPalette:(WDPalette *)palette;
- (WDPalette *)   findPrevPaletteOfPalette:(WDPalette *)palette;
- (NSArray *)     makeGradientCGColorPaletteOfWord:(WDWord *)word;
- (NSArray *)     makeGradientColorPaletteOfWord:(WDWord *)word;

- (NSUInteger)    findIndexPositionForStyle:(WDStyle *)style;

- (WDStyle *)     defaultStyle;
- (WDPalette *)   defaultPalette;
- (WDPalette *)   randomPalette;

- (WDPalette *)   findPaletteWithIdName:(NSString *)idName;

- (BOOL)          adjustWordsArrayAtPresentDay;

@end
