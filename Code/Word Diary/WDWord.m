//
//  WDWord.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWord.h"
#import "WDPalette.h"
#import "WDStyle.h"
#import "WDUtils.h"
#import "WDWordDiary.h"

@interface WDWord()

- (void)      KVCRegister;

- (NSString *) createDayAndMonthAbreviateAsString:(BOOL)abreviate;

@end

@implementation WDWord

@dynamic timeInterval;
@dynamic word;
@dynamic style;
@dynamic palette;

@synthesize dateComponents  = dateComponents_;

#pragma mark - Properties

#pragma mark - Init

- (NSDateComponents *)dateComponents
{
    if (nil == dateComponents_) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.timeInterval];
        dateComponents_ = [[WDWordDiary sharedWordDiary].currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
        //dateComponents_.calendar = [WDWordDiary sharedWordDiary].currentCalendar;
    }
    
    return dateComponents_;
}

- (void)KVCRegister
{
    [self addObserver:self forKeyPath:@"timeInterval" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"word" options:0 context:NULL];
}

- (void)awakeFromFetch
{
    [self KVCRegister];
}

- (void)awakeFromInsert
{
    [self KVCRegister];
}

#pragma mark - End

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"word"];
    [self removeObserver:self forKeyPath:@"timeInterval"];
}

#pragma mark - Compare

- (NSComparisonResult)compare:(WDWord *)otherWord
{
    NSNumber *selfValue = [NSNumber numberWithDouble:self.timeInterval];
    NSNumber *otherValue = [NSNumber numberWithDouble:otherWord.timeInterval];
    
    return [selfValue compare:otherValue];
}

#pragma mark - Comprobacion

- (BOOL)isEmpty
{
    NSString *wordTrimming = [self.word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return wordTrimming.length == 0;
}

- (BOOL)isTodayWord
{
    NSDate *wordDate = [NSDate dateWithTimeIntervalSince1970:self.timeInterval];
    NSDateComponents *dateComponentsFromToday = [[WDWordDiary sharedWordDiary].currentCalendar components:NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *dateComponentsFromWordDate = [[WDWordDiary sharedWordDiary].currentCalendar components:NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit fromDate:wordDate];
    
    return dateComponentsFromToday.year == dateComponentsFromWordDate.year &&
    dateComponentsFromToday.month == dateComponentsFromWordDate.month &&
    dateComponentsFromToday.day == dateComponentsFromWordDate.day;
}

- (NSUInteger)daysSinceTodayDate
{
    
    NSDate *todayDate = [NSDate date];
    //Falla la linea de abajo, no da siempre cambio de dia, usaremos los componentes sin el timeinterval
    //NSDate *wordDate = [NSDate dateWithTimeIntervalSince1970:self.timeInterval];
    NSDate *wordDate = [[WDWordDiary sharedWordDiary].currentCalendar dateFromComponents:self.dateComponents];
    NSDateComponents *dateComponents = [[WDWordDiary sharedWordDiary].currentCalendar components:NSDayCalendarUnit fromDate:wordDate toDate:todayDate options:0];
    
    return dateComponents.day;
}

#pragma mark - Obtencion

- (NSString *)yearAsString
{
    return [NSNumber numberWithUnsignedInteger:self.dateComponents.year].stringValue;
}

- (NSString *)createDayAndMonthAbreviateAsString:(BOOL)abreviate
{
    NSString *dayMonthDateText = nil;
    if ([WDUtils englishIsTheCurrentAppLanguage]) {
        dayMonthDateText = [NSString stringWithFormat:@"%@ %d", [WDUtils monthString:self.dateComponents.month abreviateMode:abreviate], self.dateComponents.day];
    } else {
        dayMonthDateText = [NSString stringWithFormat:@"%d %@ %@", self.dateComponents.day, NSLocalizedString(@"TAG_DATE_MONTHDAY_SEPARATOR", @""), [WDUtils monthString:self.dateComponents.month abreviateMode:abreviate]];
    }
    
    return dayMonthDateText;
}

- (NSString *)dayAndMonthAbreviateAsString
{
    return [self createDayAndMonthAbreviateAsString:YES];
}

- (NSString *)dayAndMonthAsString
{
    return [self createDayAndMonthAbreviateAsString:NO];
}

#pragma mark - Key-Value Observing

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath compare:@"timeInterval"] == NSOrderedSame) {
        dateComponents_ = nil;
    } else if ([keyPath compare:@"word"] == NSOrderedSame) {
        // Si la palabra es la actual, nos interesa para el futuro poder guardar el instante preciso de actualizacion del dato
        if ([self isTodayWord]) {
            self.timeInterval = [[NSDate date] timeIntervalSince1970];
        }
    }
}

@end
