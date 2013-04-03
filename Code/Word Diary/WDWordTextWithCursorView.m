//
//  WDWordTextWithCursorView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordTextWithCursorView.h"
#import "WDWordTextViewDataSource.h"
#import <CoreText/CoreText.h>

@implementation WDWordTextWithCursorView

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
    
    // Flip coordinate system
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    CGContextSetAllowsAntialiasing(contextRef, true);

    CGPoint startPointDraw = [self.dataSource actualStartPointDrawingForWordTextView:self];
    
    // nota: creamos un string con cursor como caracter de referencia a la hora de hallar los bounds
    NSString *wordText = [self.dataSource actualTextValueForWordTextView:self];
    NSString *wordTextWithCursor = [wordText stringByAppendingString:@"|"];
    
    NSString *familyFont = self.familyFont;
    CGFloat fontSize = [self.dataSource fontStartSize];
    
    CTLineRef line = nil;
    CGRect lineImageBoundsWithoutCursor = CGRectNull;
    CGRect lineImageBounds;
    BOOL endFindingFontSize = NO;
    do {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)familyFont, fontSize, NULL);
        NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef, (NSString *)kCTFontAttributeName,
                                        [self.dataSource actualSelectedWordColorForWordTextView:self], (NSString *)NSForegroundColorAttributeName, nil];
        CFRelease(fontRef);
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:wordTextWithCursor attributes:attrDictionary];
        //[attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithWhite:1.0 alpha:1.0] range:NSMakeRange(wordTextWithCursor.length - 1, 1)];
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithWhite:1.0 alpha:0.0] range:NSMakeRange(wordTextWithCursor.length - 1, 1)];
        
        line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attString));
        
        // Para centrar sin tener en cuenta el cursor
        // if (CGRectEqualToRect(lineImageBoundsWithoutCursor, CGRectNull)) {
        NSAttributedString *attStringWithoutCursor = [[NSAttributedString alloc] initWithString:wordText attributes:attrDictionary];
        CTLineRef lineWithoutCursor = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attStringWithoutCursor));
        lineImageBoundsWithoutCursor = CTLineGetImageBounds(lineWithoutCursor, contextRef);
        CFRelease(lineWithoutCursor);
        //}
        
        // Set text position and draw the line into the graphics context
        lineImageBounds = CTLineGetImageBounds(line, contextRef);
        endFindingFontSize = startPointDraw.x + self.frame.origin.x + lineImageBounds.size.width + 40.0 < startPointDraw.x + self.frame.origin.x + self.bounds.size.width;
        if (endFindingFontSize) {
            endFindingFontSize = lineImageBounds.size.height + 40.0 < self.bounds.size.height;
        }
        if (!endFindingFontSize) {
            fontSize--;
            CFRelease(line);
        }
    } while (!endFindingFontSize);
    
    //CTLineRef line = [self createCTLineRefAdjustedToFitWithContextRef:contextRef withText:wordText color:[UIColor blackColor] activeCursor:writeModeActive];
    CGPoint fontDrawPoint = CGPointMake(startPointDraw.x + self.frame.origin.x, startPointDraw.y);
    
    CGContextSaveGState(contextRef);
    CGContextSetTextPosition(contextRef, fontDrawPoint.x, fontDrawPoint.y);
    
    CGRect cursorBounds = CGRectMake(fontDrawPoint.x, fontDrawPoint.y, 0.0, lineImageBounds.size.height);
    if (wordText.length > 0) {
        CFArrayRef lineGlyphRuns = CTLineGetGlyphRuns(line);
        CFIndex glyphRunsCount = CFArrayGetCount(lineGlyphRuns);
        CTRunRef glyphRunRef = CFArrayGetValueAtIndex(lineGlyphRuns, glyphRunsCount - 2);
        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(glyphRunRef).location + CTRunGetStringRange(glyphRunRef).length, NULL);
        CGFloat width = CTRunGetTypographicBounds(glyphRunRef, CFRangeMake(0, 0), NULL, NULL, NULL);
        cursorBounds = CGRectMake(fontDrawPoint.x + xOffset, cursorBounds.origin.y, width, cursorBounds.size.height);
    }
        
    CGContextSaveGState(contextRef);
    CGContextSetLineWidth(contextRef, 2.0);
    CGContextSetStrokeColorWithColor(contextRef, [self.dataSource actualCursorColorForWordTextView:self].CGColor);
    CGContextMoveToPoint(contextRef, cursorBounds.origin.x + 1, cursorBounds.origin.y + fontSize * 0.75);
    CGContextAddLineToPoint(contextRef, cursorBounds.origin.x + 1, cursorBounds.origin.y - fontSize * 0.25);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
    
    CTLineDraw(line, contextRef);
    CFRelease(line);
    CGContextRestoreGState(contextRef);
    
    CGContextRestoreGState(contextRef);
}

@end
