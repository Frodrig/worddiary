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

@property(nonatomic) CGRect  lastCursorBounds;
@property(nonatomic) CGFloat lastFontSize;

- (CGFloat) scaleFontInEditMode;
- (CGFloat) scaleFontInPresentationMode;

@end

@implementation WDWordRepresentationView

#pragma mark - Synthesize

@synthesize dataSource        = dataSource_;
@synthesize keyboardMode      = keyboardMode_;
@synthesize isGosthView       = isGosthView_;
@synthesize forceCursorHide   = cursorHide_;
@synthesize delegate          = delegate_;
@synthesize lastCursorBounds  = lastCursorBounds_;
@synthesize lastFontSize      = lastFontSize_;

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
        self.lastCursorBounds = CGRectNull;
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

- (void)generateGosthWordRepresentation
{
    isGosthView_ = YES;
    
    CGRect prevFrame = self.frame;
    NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
    __block WDWordRepresentationView *gosthView = (WDWordRepresentationView *)[NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    gosthView.dataSource = self.dataSource;
    //gosthView.forceCursorHide = YES;
    
    isGosthView_ = NO;
    self.frame = prevFrame;
    
    [self.superview addSubview:gosthView];
    
    [UIView animateWithDuration:1 animations:^{
        gosthView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [gosthView removeFromSuperview];
    }];
}

#pragma mark - Auxiliary

- (CGFloat)scaleFontInEditMode
{
    CGFloat retScale = 1.0;
    
    const NSString *familyFont = [self.dataSource selectedWordTextFamilyFontForWordRepresentationView:self];
    if ([familyFont compare:@"Baskerville"] == NSOrderedSame) {
        retScale = [WDUtils is568Screen] ? 1.45 : 1.2;
    } else if ([familyFont compare:@"Zapfino"] == NSOrderedSame) {
        retScale = [WDUtils is568Screen] ? 0.6 : 0.3;
    } else if ([familyFont compare:@"PartyLetPlain"] == NSOrderedSame) {
        retScale = [WDUtils is568Screen] ? 1.5 : 1.5;
    } else if ([familyFont compare:@"SnellRoundhand"] == NSOrderedSame) {
        retScale = [WDUtils is568Screen] ? 1.3 : 1.1;
    }
    
    return retScale;
}

- (CGFloat)scaleFontInPresentationMode
{
    CGFloat retScale = 1.0;
    
    const NSString *familyFont = [self.dataSource selectedWordTextFamilyFontForWordRepresentationView:self];
    if ([familyFont compare:@"Baskerville"] == NSOrderedSame) {
        retScale = [WDUtils is568Screen] ? 1.45 : 1.2;
    } else if ([familyFont compare:@"Zapfino"] == NSOrderedSame) {
        retScale = [WDUtils is568Screen] ? 0.65 : 0.5;
    } else if ([familyFont compare:@"PartyLetPlain"] == NSOrderedSame) {
        retScale = [WDUtils is568Screen] ? 1.8 : 1.5;
    } else if ([familyFont compare:@"SnellRoundhand"] == NSOrderedSame) {
        retScale = [WDUtils is568Screen] ? 1.4 : 1.2;
    }
    
    return retScale;
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
    
    // Vbles y constantes generales
    const CGFloat dashPattern[] = {1.0, 9.0};
    const UIColor *wordColor = [self.dataSource selectedWordColorForWordRepresentationView:self];
    float wordColorRGBComponents[4];
    [wordColor getRed:&wordColorRGBComponents[0] green:&wordColorRGBComponents[1] blue:&wordColorRGBComponents[2] alpha:&wordColorRGBComponents[3]];
    NSString *wordText = [self.dataSource selectedWordTextForWordRepresentationView:self];
    const CGPoint startPointDraw = CGPointMake(0.0, self.frame.size.height * ([WDUtils is568Screen] ? 0.6 : 0.6));
    const CGPoint endPointDraw = CGPointMake(self.bounds.size.width, startPointDraw.y);
    const BOOL isEmptyText = wordText.length == 0;
    const BOOL showCursor = (isEmptyText || self.keyboardMode);

    // Línea
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 1.5);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor colorWithRed:wordColorRGBComponents[0] green:wordColorRGBComponents[1] blue:wordColorRGBComponents[2] alpha:wordText.length > 0 ? 0.4 : 1.0].CGColor);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor colorWithWhite:0.0 alpha:wordText.length > 0 ? 0.4 : 1.0].CGColor);
    CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);

    // Dibujado de la palabra si procede (no ha habido cambio de estado)
    const NSString *familyFont = [self.dataSource selectedWordTextFamilyFontForWordRepresentationView:self];
    self.lastFontSize = 100.0 * (self.keyboardMode ? [self scaleFontInEditMode] : [self scaleFontInPresentationMode]);
   
    const CGFloat wordStartPointDrawMargin = showCursor ? 15.0 : 15.0;
    const CGFloat rightWidthMargin = showCursor ? 60.0 : 15.0;
    const CGFloat finalFontSizeModulator = 25.0;
    CGFloat leftMarginAdjustmentByFont = 0.0;
    
    // Tamaño palabra
    CTLineRef line = nil;
    CGRect lineImageBounds;
    BOOL endFindingFontSize = NO;
    do {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)familyFont, self.lastFontSize, NULL);
        NSDictionary *attrDictionary = @{(NSString *)kCTFontAttributeName: (__bridge id)fontRef,
                                         (NSString *)NSForegroundColorAttributeName: wordColor};
        CFRelease(fontRef);
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:wordText attributes:attrDictionary];
        if (!showCursor) {
            [attString addAttribute:NSKernAttributeName value:[NSNumber numberWithFloat:0] range:NSMakeRange(0.0, wordText.length)];
        }
        line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attString));
        
        lineImageBounds = CTLineGetImageBounds(line, contextRef);
        leftMarginAdjustmentByFont = lineImageBounds.origin.x < 0.0 ? abs(lineImageBounds.origin.x) : -lineImageBounds.origin.x;
        endFindingFontSize = leftMarginAdjustmentByFont + startPointDraw.x + wordStartPointDrawMargin + self.frame.origin.x + lineImageBounds.size.width + rightWidthMargin + finalFontSizeModulator < leftMarginAdjustmentByFont + startPointDraw.x + wordStartPointDrawMargin + self.frame.origin.x + self.bounds.size.width;
        if (endFindingFontSize) {
            endFindingFontSize = (lineImageBounds.size.height + ((self.frame.size.height + self.frame.origin.y) - startPointDraw.y)) < self.bounds.size.height;
        }
        
        if (!endFindingFontSize) {
            self.lastFontSize--;
            CFRelease(line);
        }
    } while (!endFindingFontSize);
    
    CGPoint fontDrawPoint = showCursor ? CGPointMake(leftMarginAdjustmentByFont + startPointDraw.x + wordStartPointDrawMargin + self.frame.origin.x, startPointDraw.y) :
    CGPointMake(leftMarginAdjustmentByFont + (self.bounds.size.width - lineImageBounds.size.width) / 2, startPointDraw.y);
    self.lastCursorBounds = CGRectMake(fontDrawPoint.x, fontDrawPoint.y, 0.0, lineImageBounds.size.height);
    
    CGContextSaveGState(contextRef);
    CGContextSetTextPosition(contextRef, fontDrawPoint.x, fontDrawPoint.y);
    
    CFArrayRef lineGlyphRuns = CTLineGetGlyphRuns(line);
    CFIndex glyphRunsCount = CFArrayGetCount(lineGlyphRuns);
    CTRunRef glyphRunRef = CFArrayGetValueAtIndex(lineGlyphRuns, glyphRunsCount - 1);
    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(glyphRunRef).location + CTRunGetStringRange(glyphRunRef).length, NULL);
    CGFloat width = CTRunGetTypographicBounds(glyphRunRef, CFRangeMake(0, 0), NULL, NULL, NULL);
    self.lastCursorBounds = CGRectMake(fontDrawPoint.x + xOffset, self.lastCursorBounds.origin.y, width, self.lastCursorBounds.size.height);
    
    // Palabra
    CTLineDraw(line, contextRef);
    CFRelease(line);
    [self.delegate wordContentUpdatedFlagCheckedByWordRepresentationView:self];
    CGContextRestoreGState(contextRef);
    
    // Cursor
    if (showCursor && !self.forceCursorHide) {
        const UIColor *cursorColor = [self.dataSource selectedWordCursorColorForWordRepresentationView:self];
        CGContextSaveGState(contextRef);
        
        CGContextSetLineWidth(contextRef, 4.0);
        CGContextSetStrokeColorWithColor(contextRef, cursorColor.CGColor);
        CGContextMoveToPoint(contextRef, self.lastCursorBounds.origin.x + 1, self.lastCursorBounds.origin.y + self.lastFontSize * 0.75);
        CGContextAddLineToPoint(contextRef, self.lastCursorBounds.origin.x + 1, self.lastCursorBounds.origin.y - self.lastFontSize * 0.25);
        CGContextStrokePath(contextRef);
        
        CGContextRestoreGState(contextRef);
    }
}

@end
