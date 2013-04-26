//
//  WDDayMonthView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDayMonthView.h"
#import "WDUtils.h"

@implementation WDDayMonthView

#pragma mark - Synthesize

@synthesize index              = index_;
@synthesize dayOfMonthLabel    = dayOfTheMonthLabel_;
@synthesize initialLetterLabel = initialLetterLabel_;

#pragma mark - Init

- (id)initWithIndex:(NSUInteger)index andFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        index_ = index;
        
        dayOfTheMonthLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, frame.size.width, frame.size.height * 0.4)];
        dayOfTheMonthLabel_.textAlignment = NSTextAlignmentCenter;
        dayOfTheMonthLabel_.text = [[NSNumber numberWithUnsignedInteger:index] stringValue];
        dayOfTheMonthLabel_.textColor = [UIColor whiteColor];
        dayOfTheMonthLabel_.backgroundColor = [UIColor clearColor];
        dayOfTheMonthLabel_.opaque = YES;
        [self addSubview:dayOfTheMonthLabel_];
        
        initialLetterLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, dayOfTheMonthLabel_.frame.size.height, frame.size.width, frame.size.height - dayOfTheMonthLabel_.frame.size.height)];
        initialLetterLabel_.textAlignment = NSTextAlignmentCenter;
        initialLetterLabel_.textColor = [UIColor whiteColor];
        initialLetterLabel_.backgroundColor = [UIColor clearColor];
        initialLetterLabel_.opaque = YES;
        [self addSubview:initialLetterLabel_];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
