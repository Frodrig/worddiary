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

@interface WDWord()

- (void)      KVCRegister;

- (NSString *) createDayAndMonthAbreviateAsString:(BOOL)abreviate;

@end

@implementation WDWord

@dynamic timeInterval;
@dynamic word;
@dynamic style;
@dynamic palette;

#pragma mark - Init

@synthesize dateComponents = dateComponents_;

- (NSDateComponents *)dateComponents
{
    if (nil == dateComponents_) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.timeInterval];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        dateComponents_ = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
        dateComponents_.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
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
    NSDate *todayDate = [NSDate date];
    NSDate *wordDate = [NSDate dateWithTimeIntervalSince1970:self.timeInterval];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsFromToday = [calendar components:NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit fromDate:todayDate];
    NSDateComponents *dateComponentsFromWordDate = [calendar components:NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit fromDate:wordDate];
    
    return dateComponentsFromToday.year == dateComponentsFromWordDate.year &&
    dateComponentsFromToday.month == dateComponentsFromWordDate.month &&
    dateComponentsFromToday.day == dateComponentsFromWordDate.day;
}

- (NSUInteger)daysSinceTodayDate
{
    
    NSDate *todayDate = [NSDate date];
    NSDate *wordDate = [NSDate dateWithTimeIntervalSince1970:self.timeInterval];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit fromDate:wordDate toDate:todayDate options:0];
    
    return dateComponents.day;
    
    /*
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *wordDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:[NSDate dateWithTimeIntervalSince1970:self.timeInterval]];
    
    [NSCalendar currentCalendar] day
    */
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
