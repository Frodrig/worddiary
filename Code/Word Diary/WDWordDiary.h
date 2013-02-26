//
//  WDWordCalendar.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWord;
@class WDFont;
@class WDColor;

@interface WDWordDiary : NSObject

@property (nonatomic, readonly, strong) NSManagedObjectContext *context;
@property (nonatomic, readonly, strong) NSManagedObjectModel   *model;
@property (nonatomic, readonly, strong) NSMutableArray         *words;
@property (nonatomic, strong)           NSArray                *colors;
@property (nonatomic, strong)           NSArray                *fonts;

+ (WDWordDiary *)sharedWordDiary;

- (WDWord *)createWord:(NSString *)word inTimeInterval:(double)timeInterval withFont:(WDFont *)font andBackgroundColor:(WDColor *)backgroundColor andWordColor:(WDColor *)wordColor;
- (void)removeWord:(WDWord *)word;

- (void)saveAll;

@end
