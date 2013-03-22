//
//  WDUtils.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDUtils.h"

@implementation WDUtils

#pragma mark - Sizes

+ (CGFloat) sizeOfWordForUI:(UIWithFontType)uiType andFont:(WDFont *)font
{
    CGFloat result = 0.0;
    switch (uiType) {
        case UI_ALLWORDSSCREEN_TODAYWORD:
            result = 92.0;
            break;
        case UI_ALLWORDSSCREEN_PREVIOUSWORD:
            result = 42.0;
            break;
        case UI_SELECTEDWORDSCREEN_WORD:
            result = 180.0;
            break;
        case UI_SELECTEDWORDSCREEN_FONTMENU:
            result = 52.0;
            break;
        default:
            break;
    }

    return result;
}

#pragma mark - Text

+ (NSString *)abreviateMonthString:(NSInteger)monthIndex
{
    NSString *result = nil;
    
    switch (monthIndex) {
        case 1:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_JANUARY", @"");
            break;
        case 2:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_FEBRUARY", @"");
            break;
        case 3:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_MARCH", @"");
            break;
        case 4:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_APRIL", @"");
            break;
        case 5:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_MAY", @"");
            break;
        case 6:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_JUNE", @"");
            break;
        case 7:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_JULY", @"");
            break;
        case 8:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_AUGUST", @"");
            break;
        case 9:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_SEPTEMBER", @"");
            break;
        case 10:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_OCTOBER", @"");
            break;
        case 11:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_NOVEMBER", @"");
            break;
        case 12:
            result = NSLocalizedString(@"TAG_ABREVIATEMONTH_DECEMBER", @"");
            break;
            
        default:
            break;
    }
    
    return result;
}

+ (BOOL) englishIsTheCurrentAppLanguage
{
    return [NSLocalizedString(@"TAG_LANG", @"") caseInsensitiveCompare:@"en"] == NSOrderedSame;
}

+ (BOOL) spanishIsTheCurrentAppLanguage
{
    return ![self englishIsTheCurrentAppLanguage];
}

+ (BOOL)is:(CGFloat)floatOne equalsTo:(CGFloat)floatTwo
{
    static const CGFloat EPSILON = 0.00001;
    return (fabs(floatOne - floatTwo) < EPSILON);
}

+ (BOOL)is568Screen
{
    return [UIScreen mainScreen].bounds.size.height == 568;
}

+ (CGFloat)viewsCornerRadius
{
    return 10.0;
}

+ (UIColor *)darkSchemeBackgroundColor
{
    return [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.2];
}

+ (UIColor *)darkSchemeTextColor
{
    return [UIColor blackColor];
}

+ (UIColor *)lightSchemeBackgroundColor
{
    return [UIColor colorWithWhite:0.25 alpha:0.2];
}

+ (UIColor *)lightSchemeTextColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)schemeBackgroundColor:(WDColorScheme)scheme
{
    UIColor *color = nil;
    
    switch (scheme) {
        case CS_DARK:
            color = [self darkSchemeBackgroundColor];
            break;
            
        default:
            color = [self lightSchemeBackgroundColor];
            break;
    }
    
    return color;
}

+ (UIColor *)schemeTextColor:(WDColorScheme)scheme
{
    UIColor *color = nil;
    
    switch (scheme) {
        case CS_DARK:
            color = [self darkSchemeTextColor];
            break;
            
        case CS_LIGHT:
            color = [self lightSchemeTextColor];
        default:
            break;
    }
    
    return color;
}

+ (NSArray *)pickerColorArray
{
    /*
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.3],
                                                                    [NSNumber numberWithFloat:0.3],
                                                                    [NSNumber numberWithFloat:0.3],
                                                                    [NSNumber numberWithFloat:0.0],
                                                                    [NSNumber numberWithFloat:2.0],
                                                                    [NSNumber numberWithFloat:4.0],
                                                                    [NSNumber numberWithInteger:200],
                                                                    [NSNumber numberWithInteger:55],
                                                                    [NSNumber numberWithInteger:12],
                                                                nil]
                                                           forKeys:[NSArray arrayWithObjects:@"rFrecuency",
                                                                    @"gFrecueny",
                                                                    @"bFrecuency",
                                                                    @"rPhase",
                                                                    @"gPhase",
                                                                    @"bPhase",
                                                                    @"center",
                                                                    @"amplitude",
                                                                    @"loopLength",
                                                                    nil]];
    
    NSArray *pickerColorArray = [self.class makeColorGradientWithParameters:params];
    */
    
    NSArray *pickerColorArray = [NSArray arrayWithObjects:[UIColor colorWithRed:251.0/255.0 green:235.0/255.0 blue:0 alpha:1.0],
                                                          [UIColor colorWithRed:222.0/255.0 green:255.0/255.0 blue:0 alpha:1.0],
                                                          [UIColor colorWithRed:21/255.0 green:249.0/255.0 blue:2.0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:0/255.0 green:160.0/255.0 blue:140.0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:0/255.0 green:74.0/255.0 blue:255.0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:132.0/255.0 green:8.0/255.0 blue:255.0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:148.0/255.0 green:0/255.0 blue:156.0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:191.0/255.0 green:2.0/255.0 blue:96.0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:255.0/255.0 green:16.0/255.0 blue:0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:255.0/255.0 green:90.0/255.0 blue:4.0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:255.0/255.0 green:156.0/255.0 blue:0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:255.0/255.0 green:198.0/255.0 blue:0/255.0 alpha:1.0],
                                                          [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0],
                                 nil];
    
    return pickerColorArray;
}

+ (WDBackgroundCategory)convertPickerColorIndexToBackgroundCategory:(NSUInteger)index
{
    WDBackgroundCategory backgroundCategory = index;
    
    return backgroundCategory;
    
    /*
    switch (index) {
        case 0:
            backgroundCategory = BC_GRADIENT_0;
            break;
        case 1:
            backgroundCategory = BC_GRADIENT_1;
            break;
        case 2:
            backgroundCategory = BC_GRADIENT_2;
            break;
        case 3:
            backgroundCategory = BC_GRADIENT_3;
            break;
        case 4:
            backgroundCategory = BC_GRADIENT_4;
            break;
        case 5:
            backgroundCategory = BC_GRADIENT_5;
            break;
        case 6:
            backgroundCategory = BC_GRADIENT_6;
            break;
        case 7:
            backgroundCategory = BC_GRADIENT_7;
            break;
        case 8:
            backgroundCategory = BC_GRADIENT_8;
            break;
        case 9:
            backgroundCategory = BC_GRADIENT_9;
            break;
        case 10:
            backgroundCategory = BC_GRADIENT_10;
            break;
        case 11:
            backgroundCategory = BC_GRADIENT_11;
            break;
        default:
            break;
    };
    */
}

+ (NSUInteger)convertGradientBackgroundCategoryToPickerColorIndex:(WDBackgroundCategory)backgroundCategory
{
    NSUInteger colorIndex = backgroundCategory;
    NSAssert(colorIndex < [self pickerColorArray].count, @"Categoria recibida invalida");
    
    return colorIndex;
}

+ (NSString *)stringFromWeekday:(NSUInteger)weekDay
{
    NSString *retString = nil;
    switch (weekDay) {
        case 1:
            retString = NSLocalizedString(@"TAG_WEEKDAY_SUNDAY", @"");
        break;
        case 2:
            retString = NSLocalizedString(@"TAG_WEEKDAY_MONDAY", @"");
        break;
        case 3:
            retString = NSLocalizedString(@"TAG_WEEKDAY_TUESDAY", @"");
            break;
        case 4:
            retString = NSLocalizedString(@"TAG_WEEKDAY_WEDNESDAY", @"");
            break;
        case 5:
            retString = NSLocalizedString(@"TAG_WEEKDAY_THURSDAY", @"");
            break;
        case 6:
            retString = NSLocalizedString(@"TAG_WEEKDAY_FRIDAY", @"");
            break;
        case 7:
            retString = NSLocalizedString(@"TAG_WEEKDAY_SATURDAY", @"");
            break;
        default:
            break;
    }
    
    return retString;
}

+ (NSString *)convertNumberToStringWithTwoDigitsMin:(NSNumber *)number
{
    NSString *retNumber = number.unsignedIntegerValue < 10 ? [@"0" stringByAppendingString:number.stringValue] : number.stringValue;
    return retNumber;
}

+ (BOOL)isIPhone5Screen
{
    return [UIScreen mainScreen].bounds.size.height == 568.0;
}

+ (NSArray *)makeColorGradientWithParameters:(NSDictionary *)parameters
{
    NSNumber *rFrecuency = [parameters objectForKey:@"rFrecuency"];
    NSNumber *gFrecuency = [parameters objectForKey:@"gFrecuency"];
    NSNumber *bFrecuency = [parameters objectForKey:@"bFrecuency"];
    NSNumber *rPhase = [parameters objectForKey:@"rPhase"];
    NSNumber *gPhase = [parameters objectForKey:@"gPhase"];
    NSNumber *bPhase = [parameters objectForKey:@"bPhase"];
    NSNumber *center = [parameters objectForKey:@"center"];
    NSNumber *amplitude = [parameters objectForKey:@"amplitude"];
    NSNumber *loopLenght = [parameters objectForKey:@"loopLength"];
    
    if (center == nil) {
        center = [NSNumber numberWithUnsignedInteger:128];
    }
    if (amplitude == nil) {
        amplitude = [NSNumber numberWithUnsignedInteger:127];
    }
    if (loopLenght == nil) {
        loopLenght = [NSNumber numberWithUnsignedInteger:50];
    }
    
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:loopLenght.unsignedIntegerValue];
    for (NSUInteger inc = 0; inc < loopLenght.unsignedIntegerValue; inc++) {
        CGFloat redComponent = sin(rFrecuency.floatValue * inc + rPhase.floatValue) * amplitude.floatValue + center.floatValue;
        CGFloat greenComponent = sin(gFrecuency.floatValue * inc + gPhase.floatValue) * amplitude.floatValue + center.floatValue;
        CGFloat blueComponent = sin(bFrecuency.floatValue * inc + bPhase.floatValue) * amplitude.floatValue + center.floatValue;
        UIColor *color = [UIColor colorWithRed:redComponent/255.0 green:greenComponent/255.0 blue:blueComponent/255.0 alpha:1.0];
        [colors addObject:color];
    }
    
    return [NSArray arrayWithArray:colors];
}





@end
