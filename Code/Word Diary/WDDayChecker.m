//
//  WDMinuteChecker.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 21/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDayChecker.h"
#import "WDWordDiary.h"

@interface WDDayChecker()

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSDate  *date;

@end

@implementation WDDayChecker

#pragma mark - Synthesize

@synthesize delegate  = delegate_;
@synthesize timer     = timer_;
@synthesize date      = date_;

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        date_ = [NSDate date];
        timer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Actions

- (void)pause
{
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)resume
{
    //NSAssert(self.timer == nil, @"No debería de existir timer en este punto");
    if (self.timer != nil) {
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update:) userInfo:nil repeats:YES];
}

#pragma mark - Events

- (void)update:(NSTimer *)timer
{
    if (self.delegate) {
        NSDateComponents *actualDateComponents = [[WDWordDiary sharedWordDiary].currentCalendar components:NSCalendarUnitDay fromDate:[NSDate date]];
        NSDateComponents *previousDateComponents = [[WDWordDiary sharedWordDiary].currentCalendar components:NSCalendarUnitDay fromDate:self.date];
        if (actualDateComponents.day != previousDateComponents.day) {
            if ([self.delegate respondsToSelector:@selector(dayCheckerOnNewDay:)]) {
                [self.delegate dayCheckerOnNewDay:self];
            }
            self.date = [NSDate date];
        }
    }
}

@end
