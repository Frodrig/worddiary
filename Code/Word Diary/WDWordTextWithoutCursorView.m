//
//  WDWordTextWithoutCursorView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordTextWithoutCursorView.h"
#import "WDWordTextViewDataSource.h"
#import <CoreText/CoreText.h>
#import "WDUtils.h"

@interface WDWordTextWithoutCursorView()

@property(nonatomic, strong) NSString *lastWordText;

@end

@implementation WDWordTextWithoutCursorView

@synthesize gosthWordText = gosthWordText_;
@synthesize lastWordText  = lastWordText_;

#pragma init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.gosthWordText = [aDecoder decodeObjectForKey:@"gosthWordText"];
        lastWordText_ = nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.gosthWordText forKey:@"gosthWordText"];
    
    [super encodeWithCoder:aCoder];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

- (id)copy
{
    return [self copyWithZone:nil];
}

#pragma mark - Draw

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
    NSString *wordText = self.gosthWordText != nil ? self.gosthWordText : [self.dataSource actualTextValueForWordTextView:self];
    NSString *wordTextWithCursor = [wordText stringByAppendingString:@"|"];
    /*
    if (self.gosthWordText == nil && self.lastWordText != nil) {
        if ([self.lastWordText compare:wordText] != NSOrderedSame) {
            WDWordTextWithoutCursorView *gosthView = [self copy];
            gosthView.dataSource = self.dataSource;
            gosthView.gosthWordText = self.lastWordText;
            gosthView.userInteractionEnabled = NO;
            [self.superview insertSubview:gosthView aboveSubview:self];
            [UIView animateWithDuration:0.55 animations:^{
                gosthView.alpha = 0;
            }];
        }
    }*/
    self.lastWordText = wordText;

    NSString *familyFont = self.familyFont;
    CGFloat fontSize = [self.dataSource fontStartSize];
    
    CTLineRef line = nil;
    CGRect lineImageBoundsWithoutCursor = CGRectNull;
    CGRect lineImageBounds;
    BOOL endFindingFontSize = NO;
    do {
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)familyFont, fontSize, NULL);
        NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fontRef, (NSString *)kCTFontAttributeName,
                                        [UIColor blackColor], (NSString *)NSForegroundColorAttributeName, nil];
        CFRelease(fontRef);
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:wordTextWithCursor attributes:attrDictionary];
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
        endFindingFontSize = self.frame.origin.x + lineImageBounds.size.width + 40.0 < self.frame.origin.x + self.bounds.size.width;
        if (endFindingFontSize) {
            endFindingFontSize = lineImageBounds.size.height + 40.0 < self.bounds.size.height;
        }
        if (!endFindingFontSize) {
            fontSize--;
            CFRelease(line);
        }
    } while (!endFindingFontSize);
    
    CGPoint fontDrawPoint = CGPointMake(self.frame.origin.x + (self.bounds.size.width - lineImageBoundsWithoutCursor.size.width) / 2, startPointDraw.y);
    
    CGContextSaveGState(contextRef);
    CGContextSetTextPosition(contextRef, fontDrawPoint.x, fontDrawPoint.y);
    CTLineDraw(line, contextRef);
    CFRelease(line);
    CGContextRestoreGState(contextRef);
    
    CGContextRestoreGState(contextRef);
}

@end
