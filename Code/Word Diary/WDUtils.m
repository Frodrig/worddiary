//
//  WDUtils.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDUtils.h"
#import "UIColor+HSL.h"
#import "UIColor+hexColorCreation.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

@implementation WDUtils

#pragma mark - Sizes

+ (CGFloat) sizeOfWordForUI:(UIWithFontType)uiType andFont:(WDStyle *)font
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

+ (NSString *)monthString:(NSInteger)monthIndex abreviateMode:(BOOL)abreviate;
{
    NSString *result = nil;
    
    switch (monthIndex) {
        case 1:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_JANUARY" : @"TAG_MONTH_JANUARY", @"");
            break;
        case 2:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_FEBRUARY" : @"TAG_MONTH_FEBRUARY", @"");
            break;
        case 3:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_MARCH" : @"TAG_MONTH_MARCH", @"");
            break;
        case 4:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_APRIL" : @"TAG_MONTH_APRIL", @"");
            break;
        case 5:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_MAY" : @"TAG_MONTH_MAY", @"");
            break;
        case 6:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_JUNE" : @"TAG_MONTH_JUNE", @"");
            break;
        case 7:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_JULY" : @"TAG_MONTH_JULY", @"");
            break;
        case 8:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_AUGUST" : @"TAG_MONTH_AUGUST", @"");
            break;
        case 9:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_SEPTEMBER" : @"TAG_MONTH_SEPTEMBER", @"");
            break;
        case 10:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_OCTOBER" : @"TAG_MONTH_OCTOBER", @"");
            break;
        case 11:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_NOVEMBER" : @"TAG_MONTH_NOVEMBER", @"");
            break;
        case 12:
            result = NSLocalizedString(abreviate ? @"TAG_ABREVIATEMONTH_DECEMBER" : @"TAG_MONTH_DECEMBER", @"");
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

+ (NSString *) convertColorToString:(UIColor *)color
{
    const CGFloat *colorComponents = CGColorGetComponents(color.CGColor);
    NSString *colorString = [NSString stringWithFormat:@"%f,%f,%f,%f", colorComponents[0], colorComponents[1], colorComponents[2], colorComponents[3]];
    
    return colorString;
}

+ (UIColor *) convertStringToColor:(NSString *)string
{
    NSArray *colorComponents = [string componentsSeparatedByString:@","];
    NSString *redComponent = [colorComponents objectAtIndex:0];
    NSString *greenComponent = [colorComponents objectAtIndex:1];
    NSString *blueComponent = [colorComponents objectAtIndex:2];
    NSString *alphaComponent = [colorComponents objectAtIndex:3];
    UIColor *color = [UIColor colorWithRed:redComponent.floatValue green:greenComponent.floatValue blue:blueComponent.floatValue alpha:alphaComponent.floatValue];
    
    return color;
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
    
    /*
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
    */
    
    NSArray *pickerColorArray = [NSArray arrayWithObjects:[UIColor colorWithRed:255.0/255.0 green:247.0/255.0 blue:0 alpha:1.0],
                                 [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:224.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:0/255.0 green:255.0/255.0 blue:127.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:189.0/255.0 green:252.0/255.0 blue:201.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:255/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:122.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:181.0/255.0 green:226/255.0 blue:220.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:221.0/255.0 green:160.0/255.0 blue:122.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:181.0/255.0 green:226.0/255.0 blue:220.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:221.0/255.0 green:160.0/255.0 blue:221.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:135.0/255.0 green:206.0/255.0 blue:204/255.0 alpha:1.0],
                                 [UIColor colorWithRed:64.0/255.0 green:224.0/255.0 blue:208/255.0 alpha:1.0],
                                 [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0],
                                 nil];
    return pickerColorArray;
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

+ (CGFloat) brightnessOfColor:(UIColor *)color
{
    CGFloat rgbComponents[4];
    [color getRed:&rgbComponents[0] green:&rgbComponents[1] blue:&rgbComponents[2] alpha:&rgbComponents[3]];
    rgbComponents[0] *= 255.0;
    rgbComponents[1] *= 255.0;
    rgbComponents[2] *= 255.0;
    
    CGFloat brightness = sqrt(rgbComponents[0] * rgbComponents[0] * 0.241 + rgbComponents[1] * rgbComponents[1] * 0.691 + rgbComponents[2] * rgbComponents[2] * 0.068);
    return brightness < 130.0 ? 1 : 0;
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
    NSNumber *bwFrecuency = [parameters objectForKey:@"bwFrecuency"];
    NSNumber *rPhase = [parameters objectForKey:@"rPhase"];
    NSNumber *gPhase = [parameters objectForKey:@"gPhase"];
    NSNumber *bPhase = [parameters objectForKey:@"bPhase"];
    NSNumber *bwPhase = [parameters objectForKey:@"bwPhase"];
    NSNumber *center = [parameters objectForKey:@"center"];
    NSNumber *amplitude = [parameters objectForKey:@"amplitude"];
    NSNumber *loopLenght = [parameters objectForKey:@"loopLenght"];
    
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
        UIColor *color = nil;
        if (bwFrecuency) {
            CGFloat component = sin(bwFrecuency.floatValue * inc + bwPhase.floatValue) * amplitude.floatValue + center.floatValue;
            color = [UIColor colorWithRed:component/255.0 green:component/255.0 blue:component/255.0 alpha:1.0];
        } else {
            CGFloat redComponent = sin(rFrecuency.floatValue * inc + rPhase.floatValue) * amplitude.floatValue + center.floatValue;
            CGFloat greenComponent = sin(gFrecuency.floatValue * inc + gPhase.floatValue) * amplitude.floatValue + center.floatValue;
            CGFloat blueComponent = sin(bFrecuency.floatValue * inc + bPhase.floatValue) * amplitude.floatValue + center.floatValue;
            color = [UIColor colorWithRed:redComponent/255.0 green:greenComponent/255.0 blue:blueComponent/255.0 alpha:1.0];
        }
        [colors addObject:color];
        /*
        for (UIColor *colorToCheck in colors) {
            if (CGColorEqualToColor(color.CGColor, colorToCheck.CGColor)) {
                NSLog(@"Color %d already present", inc);
                break;
            }
        }
        */
    }
    
    return colors;
}

+ (NSArray *)makeHardcoreColorGradients
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:15 * 4];
    
    // NEUTRAL
    [array addObject:[UIColor colorWithHexadecimalValue:@"#B7A6AD" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#C8CAC0" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D3C9CE" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#BEB2A7" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D1C6BF" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#DBD7CC" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#CAB388" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D5C4A1" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#E0D4BB" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#B5B292" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#C8C5AC" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D5D3BF" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#A8ADB4" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#C3C8CD" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D2D6D9" withAlphaComponent:NO skipInitialCharacter:YES]];
    
    // DELICATE
    [array addObject:[UIColor colorWithHexadecimalValue:@"#B6D3E3" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#B9DEE1" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D0E9E7" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D7D7D1" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#E0DDD6" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#E6E4DC" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#E5D0C9" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#F0D8D2" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#F3E7E4" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#DED8B7" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#E7E3BD" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#F3F0C5" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D0C4D1" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#DDD2E3" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#E5DDEA" withAlphaComponent:NO skipInitialCharacter:YES]];
    
    // CHARMING
    [array addObject:[UIColor colorWithHexadecimalValue:@"#BC9DCA" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#C7B2D6" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#DFD5EA" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#ADC5E7" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#BAD1ED" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#C7DFF4" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#83D2E2" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#ADE0ED" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#C8E9EF" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#96D5D1" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#BCE4E5" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D7EDE6" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#B1B4B6" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#C6C8CA" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D6E2DF" withAlphaComponent:NO skipInitialCharacter:YES]];
    
    // ROMANTIC
    [array addObject:[UIColor colorWithHexadecimalValue:@"#FF5BA5" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#FF84BC" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#FFBBDA" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#DB49AC" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#E472BF" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#F0ADDB" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#9957CD" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#B07CDA" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#D1B2EA" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#438EC8" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#6BA7D6" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#A8CCE8" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#3BC6B6" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#64D4C7" withAlphaComponent:NO skipInitialCharacter:YES]];
    [array addObject:[UIColor colorWithHexadecimalValue:@"#A4E7DF" withAlphaComponent:NO skipInitialCharacter:YES]];

    return array;
}

+ (NSArray *)makeColorGradientWithHSL
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 255; i += 6) {
        UIColor *color = [UIColor colorWithHue:i/255.0 saturation:1.0 lightness:0.88 alpha:1.0];
        [array addObject:color];
        /*
        float components[4];
        [color getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
        NSLog(@"%f %f %f", components[0], components[1], components[2]);
         */
    }
  
    return array;
}

+ (UIView *)destroyViewGosthEffect:(UIView *)srcView withDuration:(CGFloat)duration andDisplacement:(CGFloat)displacement
{
    static const NSUInteger MAX_GOSTH_COUNTER = 256;
    static NSUInteger gosthCounter = 0;
    
    __block UIView *viewToApplyGosthEffect = nil;
    if (gosthCounter < MAX_GOSTH_COUNTER) {
        NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:srcView];
        viewToApplyGosthEffect = (UIView *)[NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
        [srcView.superview addSubview:viewToApplyGosthEffect];
        gosthCounter++;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:duration animations:^{
            viewToApplyGosthEffect.frame = CGRectMake(viewToApplyGosthEffect.frame.origin.x + displacement, viewToApplyGosthEffect.frame.origin.y, viewToApplyGosthEffect.frame.size.width, viewToApplyGosthEffect.frame.size.height);
            viewToApplyGosthEffect.alpha = 0.0;
        } completion:^(BOOL finished) {
            [viewToApplyGosthEffect removeFromSuperview];
            viewToApplyGosthEffect = nil;
            NSAssert(gosthCounter > 0, @"Incongruencia");
            gosthCounter--;
        }];
    }
    
    return viewToApplyGosthEffect;
}

+ (UIView *)destroyViewGosthEffect:(UIView *)srcView withDuration:(CGFloat)duration andVerticalDisplacement:(CGFloat)displacement
{
    static const NSUInteger MAX_GOSTH_COUNTER = 256;
    static NSUInteger gosthCounter = 0;
    
    __block UIView *viewToApplyGosthEffect = nil;
    if (gosthCounter < MAX_GOSTH_COUNTER) {
        NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:srcView];
        viewToApplyGosthEffect = (UIView *)[NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
        [srcView.superview addSubview:viewToApplyGosthEffect];
        gosthCounter++;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:duration animations:^{
            viewToApplyGosthEffect.frame = CGRectMake(viewToApplyGosthEffect.frame.origin.x, viewToApplyGosthEffect.frame.origin.y + displacement, viewToApplyGosthEffect.frame.size.width, viewToApplyGosthEffect.frame.size.height);
            viewToApplyGosthEffect.alpha = 0.0;
        } completion:^(BOOL finished) {
            [viewToApplyGosthEffect removeFromSuperview];
            viewToApplyGosthEffect = nil;
            NSAssert(gosthCounter > 0, @"Incongruencia");
            gosthCounter--;
        }];
    }
    
    return viewToApplyGosthEffect;
}

+ (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

 + (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

+ (BOOL)deviceCanDetectShakeMovement
{
    return [[CMMotionManager alloc] init].gyroAvailable;
}

+ (CGFloat)degreesToRadians:(CGFloat)degrees
{
    return degrees * M_PI / 180.0;
};

+ (CAGradientLayer *)createEdgeMaskLayerWithBounds:(CGRect)bounds
{
    UIColor *outerColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    UIColor *innerColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)outerColor.CGColor, (id)innerColor.CGColor, (id)innerColor.CGColor, (id)outerColor.CGColor, nil];
    gradientLayer.locations = [NSArray arrayWithObjects:@"0.0", @"0.2", @"0.8", @"1.0", nil];
    gradientLayer.bounds = bounds;
    gradientLayer.anchorPoint = CGPointZero;
    
    return gradientLayer;
}

@end
