//
//  WDWordRepresentationView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordRepresentationView.h"

@interface WDWordRepresentationView()

@end

@implementation WDWordRepresentationView

#pragma mark - Synthesize

@synthesize dataSource = dataSource_;

#pragma mark - Init

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
    NSLog(@"DrawRect");
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // Flip coordinate system
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    const CGPoint startPointDraw = CGPointMake(0.0, self.frame.size.height * 0.5);
    const CGPoint endPointDraw = CGPointMake(startPointDraw.x + self.bounds.size.width, startPointDraw.y);
    const CGFloat dashPattern[] = {2.0, 9.0};
    
    CGContextSaveGState(contextRef);
    
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 1.5);
    UIColor *color = [self.dataSource selectedWordColorForWordRepresentationView:self];
    CGFloat colorComponents[4] = {0.0, 0.0, 0.0, 1.0};
    [color getRed:&colorComponents[0] green:&colorComponents[1] blue:&colorComponents[2] alpha:&colorComponents[3]];
    CGContextSetStrokeColor(contextRef, colorComponents);
    CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    NSLog(@"%@", NSStringFromCGPoint(startPointDraw));
    NSLog(@"%@", NSStringFromCGPoint(endPointDraw));
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
}


@end
