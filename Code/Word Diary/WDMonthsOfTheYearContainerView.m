//
//  WDMonthsOfTheYearContainerView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDMonthsOfTheYearContainerView.h"

@implementation WDMonthsOfTheYearContainerView

@synthesize gridView = gridView_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        gridView_ = [[WDMonthOfTheYearContainerGridView alloc] initWithFrame:frame];
        [self addSubview:gridView_];
    }
    return self;
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
