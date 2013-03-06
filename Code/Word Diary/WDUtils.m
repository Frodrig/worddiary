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
            result = 82.0;
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


@end
