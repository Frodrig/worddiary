//
//  WDDateSelectorView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDateSelectorView.h"

@implementation WDDateSelectorView

#pragma mark - Synthesize

@synthesize dataSource = dataSource_;
@synthesize delegate   = delegate_;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
