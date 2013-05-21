//
//  WDMonthOfTheYearContainerGridView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDMonthOfTheYearContainerGridView.h"

@implementation WDMonthOfTheYearContainerGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineWidth(contextRef, 0.5);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor colorWithWhite:0.0 alpha:1.0].CGColor);
    const NSUInteger numRows = 4;
    const NSUInteger numColumns = 3;
    const CGFloat columnsDimension = self.bounds.size.width / numColumns;
    const CGFloat rowsDimension = self.bounds.size.height / numRows;
    for (NSUInteger rowIt = 0; rowIt < numRows; rowIt++) {
        CGContextSaveGState(contextRef);
        const NSUInteger yPosition = rowsDimension * rowIt;
        CGContextMoveToPoint(contextRef, 0, yPosition);
        CGContextAddLineToPoint(contextRef, self.bounds.size.width, yPosition);
        CGContextStrokePath(contextRef);
        CGContextRestoreGState(contextRef);
    }
    for (NSUInteger columnIt = 0; columnIt < numColumns - 1; columnIt++) {
        CGContextSaveGState(contextRef);
        const NSUInteger xPosition = columnsDimension + columnsDimension * columnIt;
        CGContextMoveToPoint(contextRef, xPosition, 0.0);
        CGContextAddLineToPoint(contextRef, xPosition, self.bounds.size.height);
        CGContextStrokePath(contextRef);
        CGContextRestoreGState(contextRef);
    }
    CGContextRestoreGState(contextRef);
}


@end
