//
//  WDUtils.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDUtils.h"

@implementation WDUtils

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

@end
