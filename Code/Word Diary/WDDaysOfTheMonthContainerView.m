//
//  WDDaysOfTheMonthContainerView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 29/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDaysOfTheMonthContainerView.h"

@implementation WDDaysOfTheMonthContainerView

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
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    
    // Rejilla
    
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineWidth(contextRef, 0.5);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor colorWithWhite:0.0 alpha:0.6].CGColor);
    for (NSUInteger rowIt = 0; rowIt < 4; rowIt++) {
        CGContextSaveGState(contextRef);
        const NSUInteger yPosition = 44 + 44 * rowIt;
        CGContextMoveToPoint(contextRef, 0, yPosition);
        CGContextAddLineToPoint(contextRef, self.bounds.size.width, yPosition);
        CGContextStrokePath(contextRef);
        CGContextRestoreGState(contextRef);
    }
    for (NSUInteger columnIt = 0; columnIt < 6; columnIt++) {
        CGContextSaveGState(contextRef);
        const NSUInteger xPosition = 50 + 44 * columnIt;
        CGContextMoveToPoint(contextRef, xPosition, 0.0);
        CGContextAddLineToPoint(contextRef, xPosition, self.bounds.size.height);
        CGContextStrokePath(contextRef);
        CGContextRestoreGState(contextRef);
    }
    CGContextRestoreGState(contextRef);
    
    
    // Sombras
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(contextRef, CGSizeMake(0.0, 0.5), 15.0, [UIColor colorWithWhite:1.0 alpha:1].CGColor);
    CGContextSetLineWidth(contextRef, 1.0);
    CGContextMoveToPoint(contextRef, 0, 0.0);
    CGContextAddLineToPoint(contextRef, self.frame.origin.x + self.frame.size.width, 0.0);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
    
    CGContextSaveGState(contextRef);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(contextRef, CGSizeMake(0.0, 0.5), 15.0, [UIColor colorWithWhite:1.0 alpha:1].CGColor);
    CGContextSetLineWidth(contextRef, 1);
    CGContextMoveToPoint(contextRef, 0, self.frame.size.height);
    CGContextAddLineToPoint(contextRef, self.frame.origin.x + self.frame.size.width, self.frame.size.height);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
}


@end
