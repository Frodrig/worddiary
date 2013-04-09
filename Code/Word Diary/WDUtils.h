//
//  WDUtils.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDBackgroundDefs.h"

typedef enum {
    UI_ALLWORDSSCREEN_TODAYWORD,
    UI_ALLWORDSSCREEN_PREVIOUSWORD,
    UI_SELECTEDWORDSCREEN_WORD,
    UI_SELECTEDWORDSCREEN_FONTMENU,
} UIWithFontType;

@class WDStyle;

@interface WDUtils : NSObject

+ (NSString *)           monthString:(NSInteger)monthIndex abreviateMode:(BOOL)abreviate;
+ (CGFloat)              sizeOfWordForUI:(UIWithFontType)uiType andFont:(WDStyle *)font;

+ (BOOL)                 englishIsTheCurrentAppLanguage;
+ (BOOL)                 spanishIsTheCurrentAppLanguage;

+ (BOOL)                 is:(CGFloat)floatOne equalsTo:(CGFloat)floatTwo;

+ (BOOL)                 is568Screen;

+ (CGFloat)              viewsCornerRadius;

+ (UIColor *)            darkSchemeBackgroundColor;
+ (UIColor *)            darkSchemeTextColor;
+ (UIColor *)            lightSchemeBackgroundColor;
+ (UIColor *)            lightSchemeTextColor;
+ (UIColor *)            schemeBackgroundColor:(WDColorScheme)scheme;
+ (UIColor *)            schemeTextColor:(WDColorScheme)scheme;

+ (NSArray *)            pickerColorArray;
+ (WDBackgroundCategory) convertPickerColorIndexToBackgroundCategory:(NSUInteger)index;
+ (NSUInteger)           convertGradientBackgroundCategoryToPickerColorIndex:(WDBackgroundCategory)backgroundCategory;
+ (NSArray *)            makeColorGradientWithParameters:(NSDictionary *)parameters;

+ (NSString *)           stringFromWeekday:(NSUInteger)weekDay;

+ (NSString *)           convertNumberToStringWithTwoDigitsMin:(NSNumber *)number;

+ (BOOL)                 isIPhone5Screen;

+ (UIView *)             destroyViewGosthEffect:(UIView *)srcView withDuration:(CGFloat)duration andDisplacement:(CGFloat)displacement;

+ (void)                 pauseLayer:(CALayer*)layer;
+ (void)                 resumeLayer:(CALayer*)layer;

+ (BOOL)                 deviceCanDetectShakeMovement;

@end
