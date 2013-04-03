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
@class WDEmotion;

@interface WDWordDiary : NSObject

@property (nonatomic, readonly, strong) NSManagedObjectContext *context;
@property (nonatomic, readonly, strong) NSManagedObjectModel   *model;
@property (nonatomic, readonly, strong) NSMutableArray         *words;
@property (nonatomic, strong)           NSArray                *colors;
@property (nonatomic, strong)           NSArray                *styles;
@property (nonatomic, strong)           NSArray                *emotions;
@property (nonatomic, strong)           NSArray                *palettes;

+ (WDWordDiary *) sharedWordDiary;

- (WDWord *)      createWord:(NSString *)word inTimeInterval:(double)timeInterval;
- (void)          removeWord:(WDWord *)word;

- (void)          saveAll;

- (WDWord *)      findTodayWord;
- (WDWord *)      findLastCreatedWord;
- (WDWord *)      findNextWordOf:(WDWord *)word;
- (WDWord *)      findPreviousWordOf:(WDWord *)word;
- (NSUInteger)    findIndexPositionForWord:(WDWord *)word;

- (WDEmotion *)   defaultEmotion;
- (WDStyle *)     defaultStyle;

- (void)          cutWordsArrayAtPresentDay;

@end
