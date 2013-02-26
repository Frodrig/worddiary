//
//  WDWord.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWord.h"
#import "WDColor.h"
#import "WDFont.h"

@interface WDWord ()

@end


@implementation WDWord

@dynamic timeInterval;
@dynamic word;
@dynamic font;
@dynamic wordColor;
@dynamic backgroundColor;
@synthesize dateComponents = dateComponents_;

#pragma mark - Init

- (NSDateComponents *)dateComponents
{
    if (nil == dateComponents_) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.timeInterval];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        dateComponents_ = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    }
    
    return dateComponents_;
}

- (void)awakeFromFetch
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

#pragma mark - Key-Value Observing

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath compare:@"timeInterval"] == NSOrderedSame) {
        dateComponents_ = nil;
    }
}

@end
