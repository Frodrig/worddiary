//
//  WDDateContainerView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 29/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDateContainerView.h"

@implementation WDDateContainerView

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
    /*
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(contextRef, true);
    
    CGContextSaveGState(contextRef);
    CGContextSetLineWidth(contextRef, 1.5);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor colorWithWhite:1 alpha:1.0].CGColor);
   // CGContextSetShadow(contextRef, CGSizeMake(0.0, -1.0), 5.0);
    CGContextMoveToPoint(contextRef, 0, 0);
    CGContextAddLineToPoint(contextRef, self.frame.origin.x + self.frame.size.width, 0);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
    
     CGContextSaveGState(contextRef);
     CGContextSetLineWidth(contextRef, 1.5);
     CGContextSetStrokeColorWithColor(contextRef, [UIColor colorWithWhite:1 alpha:1.0].CGColor);
     //CGContextSetShadow(contextRef, CGSizeMake(0.0, 1.0), 5.0);
     CGContextMoveToPoint(contextRef, 0, self.frame.size.height);
     CGContextAddLineToPoint(contextRef, self.frame.origin.x + self.frame.size.width, self.frame.size.height);
     CGContextStrokePath(contextRef);
     CGContextRestoreGState(contextRef);
    */
}


@end
