//
//  WDWordRepresentationView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordRepresentationView.h"
#import <CoreText/CoreText.h>

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
    
    // Constantes y vbles
    NSString *wordText = [self.dataSource selectedWordTextForWordRepresentationView:self];
    const NSString *familyFont = [self.dataSource selectedWordTextFamilyFontForWordRepresentationView:self];
    CGFloat fontSize = [self.dataSource selectedWordFontStartSizeForWordRepresentationView:self];
    const UIColor *wordColor = [self.dataSource selectedWordColorForWordRepresentationView:self];
    const BOOL isEmptyText = wordText.length == 0;
    const BOOL showCursor = isEmptyText || [self.dataSource isKeyboardActiveForWordRepresentationView:self];
    const CGPoint startPointDraw = CGPointMake(0.0, self.frame.size.height * 0.5);
    const CGPoint endPointDraw = CGPointMake(startPointDraw.x + self.bounds.size.width, startPointDraw.y);
    const CGFloat dashPattern[] = {2.0, 9.0};
    
    // Línea
    CGContextSaveGState(contextRef);
    
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 1.5);
    CGContextSetStrokeColorWithColor(contextRef, wordColor.CGColor);
    CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    NSLog(@"%@", NSStringFromCGPoint(startPointDraw));
    NSLog(@"%@", NSStringFromCGPoint(endPointDraw));
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
    
    // Palabra
    CTLineRef line = nil;
    CGRect lineImageBounds;
    BOOL endFindingFontSize = NO;
    do {
        // familyFont ES NULL!!!
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)familyFont, fontSize, NULL);
        NSDictionary *attrDictionary = @{(NSString *)kCTFontAttributeName: (__bridge id)fontRef,
                                         (NSString *)NSForegroundColorAttributeName: wordColor};
        CFRelease(fontRef);
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:wordText attributes:attrDictionary];
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithWhite:1.0 alpha:0.0] range:NSMakeRange(wordText.length - 1, 1)];
        
        line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attString));
        
        // Para centrar sin tener en cuenta el cursor
        // if (CGRectEqualToRect(lineImageBoundsWithoutCursor, CGRectNull)) {
        NSAttributedString *attStringWithoutCursor = [[NSAttributedString alloc] initWithString:wordText attributes:attrDictionary];
        CTLineRef lineWithoutCursor = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attStringWithoutCursor));
        //lineImageBoundsWithoutCursor = CTLineGetImageBounds(lineWithoutCursor, contextRef);
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

    
    // Cursor
    if (showCursor) {
        CGContextSaveGState(contextRef);
        
        CGContextSetLineWidth(contextRef, 2.0);
        CGContextSetStrokeColorWithColor(contextRef, wordColor.CGColor);//[self.dataSource actualCursorColorForWordTextView:self].CGColor);
        CGContextMoveToPoint(contextRef, cursorBounds.origin.x + 1, cursorBounds.origin.y + fontSize * 0.75);
        CGContextAddLineToPoint(contextRef, cursorBounds.origin.x + 1, cursorBounds.origin.y - fontSize * 0.25);
        CGContextStrokePath(contextRef);
        
        CGContextRestoreGState(contextRef);
    }
    
}


@end
