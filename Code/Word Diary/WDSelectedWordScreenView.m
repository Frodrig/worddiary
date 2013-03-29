//
//  WDSelectedWordScreenView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 29/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSelectedWordScreenView.h"

@implementation WDSelectedWordScreenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();

    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineWidth(contextRef, 4);
    CGContextSetRGBStrokeColor(contextRef, 1, 1, 1, 1.0);
    CGContextMoveToPoint(contextRef, 50.0, 0.0);
    CGContextAddLineToPoint(contextRef, 50.0, self.bounds.size.height);
    CGContextRestoreGState(contextRef);
}

@end
