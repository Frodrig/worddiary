//
//  WDWord.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 06/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWord.h"
#import "WDFont.h"


@implementation WDWord

@dynamic timeInterval;
@dynamic word;
@dynamic backgroundCategory;
@dynamic font;

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

- (void)awakeFromFetch
{
    [self addObserver:self forKeyPath:@"timeInterval" options:0 context:NULL];
}

- (void)awakeFromInsert
{
    [self addObserver:self forKeyPath:@"timeInterval" options:0 context:NULL];
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

#pragma mark - Key-Value Observing

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath compare:@"timeInterval"] == NSOrderedSame) {
        dateComponents_ = nil;
    }
}

@end
