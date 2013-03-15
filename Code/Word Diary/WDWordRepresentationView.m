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

@interface WDWordRepresentationView()

@property (weak, nonatomic) IBOutlet UIView *drawTextBox;

@end

@implementation WDWordRepresentationView

#pragma mark - Syntehsize

@synthesize dayDiaryLabel     = dayDiaryLabel_;
@synthesize drawTextBox       = drawTextBox_;
@synthesize dayMonthWordLabel = dayMonthWordLabel;
@synthesize yearWordLabel     = yearWordLabel_;
@synthesize delegate          = delegate_;
@synthesize dataSource        = dataSource_;

#pragma mark - Init

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
    const CGFloat dashPattern[] = {2.0, 10.0};

    CGContextSaveGState(contextRef);
    
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 0.5);
    CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 0.8);
    CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
    
    NSString *wordText = [self.dataSource actualTextValueForWordRepresentationView:self];
    NSString *familyFont = [self.dataSource actualFamilyFontForWordRepresentationView:self];
    CGFloat fontSize = 100;

    CTLineRef line = nil;
    CGRect lineImageBounds;
    BOOL endFindingFontSize = NO;
    do {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)familyFont, fontSize, NULL);
        NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef, (NSString *)kCTFontAttributeName,
                                        [UIColor blackColor], (NSString *)NSForegroundColorAttributeName, nil];
        CFRelease(fontRef);
        
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:wordText attributes:attrDictionary];
        line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(attString));
        
        // Set text position and draw the line into the graphics context
        lineImageBounds = CTLineGetImageBounds(line, contextRef);
        endFindingFontSize = self.drawTextBox.frame.origin.x + lineImageBounds.size.width + 40.0 < self.drawTextBox.frame.origin.x + self.drawTextBox.bounds.size.width;
        if (endFindingFontSize) {
            endFindingFontSize = lineImageBounds.size.height + 40.0 < self.drawTextBox.bounds.size.height;
        }
        if (!endFindingFontSize) {
            fontSize--;
            CFRelease(line);
        }
    } while (!endFindingFontSize);
    
    CGPoint fontDrawPoint = CGPointMake(self.drawTextBox.frame.origin.x + (self.drawTextBox.bounds.size.width - lineImageBounds.size.width) / 2, startPointDraw.y);

    CGContextSaveGState(contextRef);

    CGContextSetTextPosition(contextRef, fontDrawPoint.x, fontDrawPoint.y);
    CTLineDraw(line, contextRef);
    CFRelease(line);
    
    CGContextRestoreGState(contextRef);

    /*
    if (wordText.length == 0) {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)familyFont, fontSize, NULL);
        NSDictionary *placeholderAttrDic = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef, (NSString *)kCTFontAttributeName, [UIColor colorWithWhite:0.5 alpha:0.4], (NSString *)NSForegroundColorAttributeName, nil];
        NSAttributedString *placeholderAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TAG_PLACEHOLDER_WORD", @"") attributes:placeholderAttrDic];
        CTLineRef placeholderLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(placeholderAttributedString));
        
        CGContextSaveGState(contextRef);
        
        CGContextSetTextPosition(contextRef, fontDrawPoint.x, fontDrawPoint.y);
        CTLineDraw(placeholderLine, contextRef);
        CFRelease(placeholderLine);
        
        CGContextRestoreGState(contextRef);
    }
     */
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
