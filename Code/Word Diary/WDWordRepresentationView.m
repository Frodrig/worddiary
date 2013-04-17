//
//  WDWordRepresentationView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordRepresentationView.h"
#import "WDUtils.h"
#import <CoreText/CoreText.h>

@interface WDWordRepresentationView()

@end

@implementation WDWordRepresentationView

#pragma mark - Synthesize

@synthesize dataSource   = dataSource_;
@synthesize keyboardMode = keyboardMode_;
@synthesize isGosthView  = isGosthView_;
@synthesize forceCursorHide   = cursorHide_;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        keyboardMode_ = [aDecoder decodeBoolForKey:@"keyboardMode"];
        isGosthView_ = [aDecoder decodeBoolForKey:@"gosthView"];
        cursorHide_  = [aDecoder decodeBoolForKey:@"forceCursorHide"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.keyboardMode forKey:@"keyboardMode"];
    [aCoder encodeBool:self.isGosthView forKey:@"gosthView"];
    [aCoder encodeBool:self.forceCursorHide forKey:@"forceCursorHide"];
    
    [super encodeWithCoder:aCoder];
}

#pragma mark - Actions

- (void) generateGosthWordRepresentation
{
    isGosthView_ = YES;
    
    CGRect prevFrame = self.frame;
    NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
    __block WDWordRepresentationView *gosthView = (WDWordRepresentationView *)[NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    gosthView.dataSource = self.dataSource;
    gosthView.forceCursorHide = YES;
    
    isGosthView_ = NO;
    self.frame = prevFrame;
    
    [self.superview addSubview:gosthView];
    
    [UIView animateWithDuration:1 animations:^{
        gosthView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [gosthView removeFromSuperview];
    }];
}

#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
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
    const UIColor *cursorColor = [self.dataSource selectedWordCursorColorForWordRepresentationView:self];
    const BOOL isEmptyText = wordText.length == 0;
    const BOOL showCursor = (isEmptyText || self.keyboardMode);
    const CGPoint startPointDraw = CGPointMake(0.0, self.frame.size.height * 0.45);
    const CGPoint endPointDraw = CGPointMake(self.bounds.size.width, startPointDraw.y);
    const CGFloat wordStartPointDrawMargin = 15.0;
        
    const CGFloat dashPattern[] = {2.0, 9.0};
    
    // Línea
    CGContextSaveGState(contextRef);
    
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 1.5);
    CGContextSetStrokeColorWithColor(contextRef, wordColor.CGColor);
    CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
    
    // Palabra
    CTLineRef line = nil;
    CGRect lineImageBounds;
    BOOL endFindingFontSize = NO;
    do {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)familyFont, fontSize, NULL);
        NSDictionary *attrDictionary = @{(NSString *)kCTFontAttributeName: (__bridge id)fontRef,
                                         (NSString *)NSForegroundColorAttributeName: wordColor};
        CFRelease(fontRef);
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:wordText attributes:attrDictionary];
        line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attString));
    
        lineImageBounds = CTLineGetImageBounds(line, contextRef);
        endFindingFontSize = startPointDraw.x + wordStartPointDrawMargin + self.frame.origin.x + lineImageBounds.size.width + 40.0 < startPointDraw.x + wordStartPointDrawMargin +self.frame.origin.x + self.bounds.size.width;
        if (endFindingFontSize) {
            endFindingFontSize = lineImageBounds.size.height + 40.0 < self.bounds.size.height;
        }
        if (!endFindingFontSize) {
            fontSize--;
            CFRelease(line);
        }
    } while (!endFindingFontSize);
    
    CGPoint fontDrawPoint = showCursor ? CGPointMake(startPointDraw.x + wordStartPointDrawMargin + self.frame.origin.x, startPointDraw.y) :
                                         CGPointMake((self.bounds.size.width - lineImageBounds.size.width) / 2, startPointDraw.y);
    
    CGContextSaveGState(contextRef);
    CGContextSetTextPosition(contextRef, fontDrawPoint.x, fontDrawPoint.y);
    
    CGRect cursorBounds = CGRectNull;
    if (showCursor && !self.forceCursorHide) {
        cursorBounds = CGRectMake(fontDrawPoint.x, fontDrawPoint.y, 0.0, lineImageBounds.size.height);
        if (wordText.length > 0) {
            CFArrayRef lineGlyphRuns = CTLineGetGlyphRuns(line);
            CFIndex glyphRunsCount = CFArrayGetCount(lineGlyphRuns);
            CTRunRef glyphRunRef = CFArrayGetValueAtIndex(lineGlyphRuns, glyphRunsCount - 1);
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(glyphRunRef).location + CTRunGetStringRange(glyphRunRef).length, NULL);
            CGFloat width = CTRunGetTypographicBounds(glyphRunRef, CFRangeMake(0, 0), NULL, NULL, NULL);
            cursorBounds = CGRectMake(fontDrawPoint.x + xOffset, cursorBounds.origin.y, width, cursorBounds.size.height);
        }
    }

    // Cursor
    if (showCursor && !self.forceCursorHide) {
        CGContextSaveGState(contextRef);
        
        CGContextSetLineWidth(contextRef, 2.0);
        CGContextSetStrokeColorWithColor(contextRef, cursorColor.CGColor);
        CGContextMoveToPoint(contextRef, cursorBounds.origin.x + 1, cursorBounds.origin.y + fontSize * 0.75);
        CGContextAddLineToPoint(contextRef, cursorBounds.origin.x + 1, cursorBounds.origin.y - fontSize * 0.25);
        CGContextStrokePath(contextRef);
        
        CGContextRestoreGState(contextRef);
    }
    
    // Palabra    
    CTLineDraw(line, contextRef);
    CFRelease(line);
    CGContextRestoreGState(contextRef);
}

@end
