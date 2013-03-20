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
#import "WDWordTextWithCursorView.h"
#import "WDWordTextWithoutCursorView.h"

static CGFloat CURSOR_OPACITY = 0.1;

@interface WDWordRepresentationView()

@property (weak, nonatomic) IBOutlet UIView               *drawTextBox;
@property (nonatomic) UIColor                             *actualColorOfCursor;
@property (nonatomic, readonly) CGPoint                   startDrawingPosition;
@property (nonatomic, strong) WDWordTextWithCursorView    *wordTextWithCursorView;
@property (nonatomic, strong) WDWordTextWithoutCursorView *wordTextWithoutCursorView;

- (void)setWordTextView:(UIView *)setView andQuitWordTextView:(UIView *)quitView withDuration:(CGFloat)duration;

@end

@implementation WDWordRepresentationView

#pragma mark - Syntehsize

@synthesize dayDiaryLabel             = dayDiaryLabel_;
@synthesize drawTextBox               = drawTextBox_;
@synthesize delegate                  = delegate_;
@synthesize dataSource                = dataSource_;
@synthesize actualColorOfCursor       = actualColorOfCursor_;
@synthesize dayOfTheWeekLabel         = dayOfTheWeekLabel_;
@synthesize startDrawingPosition      = startDrawingPosition_;
@synthesize wordTextWithCursorView    = wordTextWithCursorView_;
@synthesize wordTextWithoutCursorView = wordTextWithoutCursorView_;

#pragma mark - Properties

- (UIColor *)getActualColorOfCursor
{
    if (nil == actualColorOfCursor_) {
    }

    return actualColorOfCursor_;
}

- (CGPoint)startDrawingPosition
{
    return CGPointMake(0.0, (self.frame.origin.y + self.frame.size.height - self.frame.origin.y) * 0.5);
}

#pragma mark - Init

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
        
        wordTextWithCursorView_ = [[WDWordTextWithCursorView alloc] initWithFrame:self.frame];
        wordTextWithCursorView_.backgroundColor = [UIColor clearColor];
        wordTextWithCursorView_.dataSource = self;
        
        wordTextWithoutCursorView_ = [[WDWordTextWithoutCursorView alloc] initWithFrame:self.frame];
        wordTextWithoutCursorView_.backgroundColor = [UIColor clearColor];
        wordTextWithoutCursorView_.dataSource = self;
        
        //timeFrom_ = [NSDate timeIntervalSinceReferenceDate];
        //acumulateTime_ = 0;
    }
    return self;
}

#pragma mark - Auxiliary

- (void)setWordTextView:(UIView *)setView andQuitWordTextView:(UIView *)quitView withDuration:(CGFloat)duration
{
    NSAssert(quitView.superview == self, @"La view a quitar tiene que estar en la jerarquia propia");
    
    setView.alpha = 0.0;
    [self addSubview:setView];
    [UIView animateWithDuration:duration animations:^{
        setView.alpha = 1.0;
        quitView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [quitView removeFromSuperview];
    }];
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

#pragma mark - Updates

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

#pragma mark - SetModes

- (void)setWithCursor:(CGFloat)duration;
{
    // Nota: Puede que llegue este mensaje pese a estar con cursor ya que no haya palabra vinculada y se saque el teclado.
    //       En este caso no hacemos nada.
    if (self.wordTextWithCursorView.superview == nil) {
        if ([WDUtils is:duration equalsTo:0.0]) {
            [self.wordTextWithoutCursorView removeFromSuperview];
            [self addSubview:self.wordTextWithCursorView];
        } else {
            [self setWordTextView:self.wordTextWithCursorView andQuitWordTextView:self.wordTextWithoutCursorView withDuration:duration];
        }
    }
}

- (void)setWithoutCursor:(CGFloat)duration;
{
    if ([WDUtils is:duration equalsTo:0.0]) {
        [self.wordTextWithCursorView removeFromSuperview];
        [self addSubview:self.wordTextWithoutCursorView];
    } else {
        [self setWordTextView:self.wordTextWithoutCursorView andQuitWordTextView:self.wordTextWithCursorView withDuration:duration];
    }
}

#pragma mark - Draw
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    
    CGPoint startPointDraw = self.startDrawingPosition;
    CGPoint endPointDraw = CGPointMake(self.bounds.size.width, startPointDraw.y);
    
    // Linea de puntos
    const CGFloat dashPattern[] = {2.0, 6.0};
    CGContextSaveGState(contextRef);
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 0.5);
    CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 0.8);
    CGContextMoveToPoint(contextRef, 0.0, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, self.bounds.size.width, endPointDraw.y);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
    
    CGContextRestoreGState(contextRef);
    
    //if (self.wordTextWithCursorView.superview != nil) {
        [self.wordTextWithCursorView setNeedsDisplay];
    //} else if (self.wordTextWithoutCursorView.superview != nil) {
        [self.wordTextWithoutCursorView setNeedsDisplay];
    //}
    
    [self setNeedsDisplay];
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

#pragma mark - WDWordTextViewDataSource

- (NSString *)actualTextValueForWordTextView:(WDWordTextView *)wordTextView
{
    return [self.dataSource actualTextValueForWordRepresentationView:self];
}

- (NSString *)actualFamilyFontForWordTextView:(WDWordTextView *)wordTextView
{
    return [self.dataSource actualFamilyFontForWordRepresentationView:self];
}

- (UIColor *)actualCursorColorForWordTextView:(WDWordTextView *)wordTextView
{
    return self.actualColorOfCursor;
}

- (CGPoint)actualStartPointDrawingForWordTextView:(WDWordTextView *)wordTextView
{
    return self.startDrawingPosition;
}

- (BOOL)isInWritingModeForWordTextView:(WDWordTextView *)wordTextView
{
    return [self.dataSource isInWritingModeFoWordRepresentationView:self];
}

@end
