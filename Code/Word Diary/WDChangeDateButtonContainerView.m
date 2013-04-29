//
//  WDChangeDateButtonContainerView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 29/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDChangeDateButtonContainerView.h"

@implementation WDChangeDateButtonContainerView

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
    
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(contextRef, CGSizeMake(0.0, 0.5), 8.0, [UIColor colorWithWhite:1.0 alpha:0.4].CGColor);
    CGContextSetLineWidth(contextRef, 1.0);
    CGContextMoveToPoint(contextRef, 0, 0.0);
    CGContextAddLineToPoint(contextRef, self.frame.origin.x + self.frame.size.width, 0.0);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
}

@end
