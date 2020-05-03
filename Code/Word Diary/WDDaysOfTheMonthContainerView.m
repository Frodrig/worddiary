//
//  WDDaysOfTheMonthContainerView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 29/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDaysOfTheMonthContainerView.h"

@implementation WDDaysOfTheMonthContainerView

@synthesize gridView = gridView_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.autoresizesSubviews = YES;
        gridView_ = [[WDDaysOfTheMonthContainerGridView alloc] initWithFrame:self.frame];
        [self addSubview:gridView_];
    }
    
    return self;
}

- (void) setNeedsDisplay
{
    [self.subviews makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    [super setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();

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
