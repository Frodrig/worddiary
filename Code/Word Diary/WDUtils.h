//
//  WDUtils.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    UI_ALLWORDSSCREEN_TODAYWORD,
    UI_ALLWORDSSCREEN_PREVIOUSWORD,
    UI_SELECTEDWORDSCREEN_WORD,
    UI_SELECTEDWORDSCREEN_FONTMENU,
} UIWithFontType;

@class WDFont;

@interface WDUtils : NSObject

+ (NSString *) abreviateMonthString:(NSInteger)monthIndex;
+ (CGFloat)    sizeOfWordForUI:(UIWithFontType)uiType andFont:(WDFont *)font;

@end
