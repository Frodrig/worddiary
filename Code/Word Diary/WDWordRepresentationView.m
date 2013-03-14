//
//  WDWordRepresentationView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 13/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordRepresentationView.h"

@implementation WDWordRepresentationView

#pragma mark - Syntehsize

@synthesize wordTextField = wordTextField_;
@synthesize dayDiaryLabel = dayDiaryLabel_;

#pragma mark - Init

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    
    CGPoint startPointDraw = CGPointMake(self.wordTextField.frame.origin.x, self.wordTextField.frame.origin.y + self.wordTextField.frame.size.height);
    CGPoint endPointDraw = CGPointMake(self.wordTextField.frame.origin.x + self.wordTextField.frame.size.width, self.wordTextField.frame.origin.y + self.wordTextField.frame.size.height);
    
    const CGFloat dashPattern[] = {2.0, 10.0};
    
    CGContextSetAllowsAntialiasing(contextRef, false);
    
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 1.0);
    CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 1.0);
    
    CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
}


@end
