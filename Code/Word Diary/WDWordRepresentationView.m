//
//  WDWordRepresentationView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 13/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordRepresentationView.h"
#import <CoreText/CoreText.h>
#import "WDWord.h"
#import "WDUtils.h"

static CGFloat CURSOR_OPACITY = 0.1;

@interface WDWordRepresentationView()

@property (weak, nonatomic) IBOutlet UIView *drawTextBox;
//@property (nonatomic) NSTimeInterval        timeFrom;
//@property (nonatomic) NSTimeInterval        acumulateTime;
@property (nonatomic) UIColor               *actualColorOfCursor;

//- (void)updateAnimation;
-(CTLineRef)createCTLineRefAdjustedToFitWithContextRef:(CGContextRef)contextRef withText:(NSString *)text color:(UIColor *)color activeCursor:(BOOL)cursor;

@end

@implementation WDWordRepresentationView

#pragma mark - Syntehsize

@synthesize dayDiaryLabel       = dayDiaryLabel_;
@synthesize drawTextBox         = drawTextBox_;
@synthesize delegate            = delegate_;
@synthesize dataSource          = dataSource_;
//@synthesize timeFrom            = timeFrom_;
//@synthesize acumulateTime       = acumulateTime_;
@synthesize actualColorOfCursor = actualColorOfCursor_;

#pragma mark - Properties

- (UIColor *)getActualColorOfCursor
{
    if (nil == actualColorOfCursor_) {
    }

    return actualColorOfCursor_;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Implementation code...
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        actualColorOfCursor_ = [UIColor colorWithWhite:0.0 alpha:1.0];
        //timeFrom_ = [NSDate timeIntervalSinceReferenceDate];
        //acumulateTime_ = 0;
    }
    return self;
}

#pragma mark - Animation

/*
- (void)updateAnimation
{
    NSTimeInterval timeNow = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval timeSinceLastDraw = timeNow - self.timeFrom;
    self.acumulateTime += timeSinceLastDraw;
    
    const CGFloat animationTime = 0.5;
    CGFloat interpolateValue = MIN(self.acumulateTime / animationTime, animationTime);
    NSLog(@"interpolatevalue %f",  interpolateValue);
    if ([WDUtils is:interpolateValue equalsTo:animationTime]) {
        CGFloat whiteValue = 0.0;
        CGFloat alphaValue = 0.0;
        [self.actualColorOfCursor getWhite:&whiteValue alpha:&alphaValue];
        if ([WDUtils is:alphaValue equalsTo:0.5]) {
            self.actualColorOfCursor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } else {
            self.actualColorOfCursor = [UIColor colorWithWhite:0.0 alpha:0.5];
        }
        
        self.timeFrom = timeNow;
        self.acumulateTime = 0;
    }
}
*/

- (void)updateCursorAnimation
{
    CGFloat whiteValue = 0.0;
    CGFloat alphaValue = 0.0;
    [self.actualColorOfCursor getWhite:&whiteValue alpha:&alphaValue];
    if ([WDUtils is:alphaValue equalsTo:CURSOR_OPACITY]) {
        self.actualColorOfCursor = [UIColor colorWithWhite:0.0 alpha:1.0];
    } else {
        self.actualColorOfCursor = [UIColor colorWithWhite:0.0 alpha:CURSOR_OPACITY];
    }
}


#pragma mark - Draw
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{    
    // Drawing code
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(contextRef, true);
    
    // Flip coordinate system
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    const CGPoint startWordDrawingPoint = CGPointMake(0.0, (self.drawTextBox.frame.origin.y + self.drawTextBox.frame.size.height - self.drawTextBox.frame.origin.y) * 0.5);
    
    CGPoint startPointDraw = startWordDrawingPoint;
    CGPoint endPointDraw = CGPointMake(self.bounds.size.width, startPointDraw.y);
    const CGFloat dashPattern[] = {2.0, 6.0};

    CGContextSaveGState(contextRef);
    
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 0.5);
    CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 0.8);
    CGContextMoveToPoint(contextRef, 0.0, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, self.bounds.size.width, endPointDraw.y);
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
      
    NSString *wordText = [self.dataSource actualTextValueForWordRepresentationView:self];
    BOOL writeModeActive = [self.dataSource isInWritingModeFoWordRepresentationView:self] && wordText.length > 0;
    CTLineRef line = [self createCTLineRefAdjustedToFitWithContextRef:contextRef withText:wordText color:[UIColor blackColor] activeCursor:writeModeActive];

    CGRect lineImageBounds = CTLineGetImageBounds(line, contextRef);
    CGPoint fontDrawPoint = CGPointMake(writeModeActive ? self.drawTextBox.frame.origin.x : self.drawTextBox.frame.origin.x + (self.drawTextBox.bounds.size.width - lineImageBounds.size.width) / 2, startPointDraw.y);

    CGContextSaveGState(contextRef);

    CGContextSetTextPosition(contextRef, fontDrawPoint.x, fontDrawPoint.y);
    CTLineDraw(line, contextRef);
    CFRelease(line);
    
    CGContextRestoreGState(contextRef);

    
    if (wordText.length == 0) { 
        CTLineRef placeholderLine = [self createCTLineRefAdjustedToFitWithContextRef:contextRef withText:NSLocalizedString(@"TAG_PLACEHOLDER_WORD", @"") color:self.actualColorOfCursor activeCursor:NO];
        //CGRect lineImageBounds = CTLineGetImageBounds(placeholderLine, contextRef);
        CGPoint fontDrawPoint = CGPointMake(self.drawTextBox.frame.origin.x , startPointDraw.y);

        CGContextSaveGState(contextRef);
        CGContextSetTextPosition(contextRef, fontDrawPoint.x, fontDrawPoint.y);
        CTLineDraw(placeholderLine, contextRef);
        CFRelease(placeholderLine);
        
        CGContextRestoreGState(contextRef);
    }
    
    [self setNeedsDisplay];
}

-(CTLineRef)createCTLineRefAdjustedToFitWithContextRef:(CGContextRef)contextRef withText:(NSString *)text color:(UIColor *)color activeCursor:(BOOL)cursor
{
    NSString *textToWrite = cursor ? [text stringByAppendingString:@"|"] : text;
    NSString *familyFont = [self.dataSource actualFamilyFontForWordRepresentationView:self];
    CGFloat fontSize = 100;
    
    CTLineRef line = nil;
    BOOL endFindingFontSize = NO;
    do {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)familyFont, fontSize, NULL);
        NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef, (NSString *)kCTFontAttributeName,
                                        color, (NSString *)NSForegroundColorAttributeName, nil];
        CFRelease(fontRef);
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:textToWrite attributes:attrDictionary];
        if (cursor) {
            [attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:self.actualColorOfCursor range:NSMakeRange(textToWrite.length - 1, 1)];
            //CTFontRef cursorFont = CTFontCreateWithName((__bridge CFStringRef)@"Courier", fontSize, NULL);
            //[attString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)(cursorFont) range:NSMakeRange(textToWrite.length - 1, 1)];
            //CFRelease(cursorFont);
        }
        
        line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attString));
        
        // Set text position and draw the line into the graphics context
        CGRect lineImageBounds = CTLineGetImageBounds(line, contextRef);
        endFindingFontSize = self.drawTextBox.frame.origin.x + lineImageBounds.size.width + 40.0 < self.drawTextBox.frame.origin.x + self.drawTextBox.bounds.size.width;
        if (endFindingFontSize) {
            endFindingFontSize = lineImageBounds.size.height + 40.0 < self.drawTextBox.bounds.size.height;
        }
        if (!endFindingFontSize) {
            fontSize--;
            CFRelease(line);
        }
    } while (!endFindingFontSize);

    return line;
}

#pragma mark - UIView sobrecarga

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIKeyInput

- (void)deleteBackward
{
    [self.delegate deleteBackwardsOnWordRepresentationView:self];
}

- (BOOL)hasText
{
    NSString *text = [self.dataSource actualTextValueForWordRepresentationView:self];
    return text.length > 0;
}

- (void)insertText:(NSString *)text
{
    [self.delegate wordRepresentationView:self insertText:text];
}

@end
