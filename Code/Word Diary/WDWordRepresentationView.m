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
static CGFloat FONT_START_SIZE = 100.0;

@interface WDWordRepresentationView()

@property (weak, nonatomic) IBOutlet UIView               *drawTextBox;
@property (nonatomic, strong) UIColor                     *actualColorOfCursor;
@property (nonatomic, readonly) CGPoint                   startDrawingPosition;
@property (nonatomic, strong) WDWordTextWithCursorView    *wordTextWithCursorView;
@property (nonatomic, strong) WDWordTextWithoutCursorView *wordTextWithoutCursorView;
@property (nonatomic, strong) NSMutableArray              *wordTextWithoutCursorFontTransitionsView;

- (void)setWordTextView:(UIView *)setView andQuitWordTextView:(UIView *)quitView withDuration:(CGFloat)duration;

@end

@implementation WDWordRepresentationView

#pragma mark - Syntehsize

@synthesize drawTextBox                              = drawTextBox_;
@synthesize delegate                                 = delegate_;
@synthesize dataSource                               = dataSource_;
@synthesize actualColorOfCursor                      = actualColorOfCursor_;
@synthesize startDrawingPosition                     = startDrawingPosition_;
@synthesize wordTextWithCursorView                   = wordTextWithCursorView_;
@synthesize wordTextWithoutCursorView                = wordTextWithoutCursorView_;
@synthesize wordTextWithoutCursorFontTransitionsView = wordTextWithoutCursorFontTransitionsView_;

#pragma mark - Properties

- (UIColor *)actualColorOfCursor
{
    if (nil == actualColorOfCursor_) {
        actualColorOfCursor_ = [[self.dataSource actualSelectedWordAccessoriesWordRepresentation:self] copy];
    }

    return actualColorOfCursor_;
}

- (CGPoint)startDrawingPosition
{
    return CGPointMake(10.0, self.frame.size.height * 0.3);
}

- (NSMutableArray *)wordTextWithoutCursorFontTransitionsView
{
    if (nil == wordTextWithoutCursorFontTransitionsView_) {
        wordTextWithoutCursorFontTransitionsView_ = [NSMutableArray array];
    }
    
    return wordTextWithoutCursorFontTransitionsView_;
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
        wordTextWithCursorView_ = [[WDWordTextWithCursorView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        wordTextWithCursorView_.backgroundColor = [UIColor clearColor];
        wordTextWithCursorView_.dataSource = self;
        wordTextWithCursorView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        wordTextWithoutCursorView_ = [[WDWordTextWithoutCursorView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        wordTextWithoutCursorView_.backgroundColor = [UIColor clearColor];
        wordTextWithoutCursorView_.dataSource = self;
        wordTextWithoutCursorView_.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
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
    [self insertSubview:setView atIndex:0];
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

- (void)familyFontOfSelectedWordChanged
{
    // Nota: - Las transiciones se guardan en un array para soportar multiples pulsaciones
    if ([self.dataSource actualTextValueForWordRepresentationView:self].length > 0) {
        WDWordTextWithoutCursorView *oldWordTextView = self.wordTextWithoutCursorFontTransitionsView.count > 0 ? self.wordTextWithoutCursorFontTransitionsView.lastObject : self.wordTextWithoutCursorView;
        CGRect oldWordTextOriginalFrame = oldWordTextView.frame;
        CGPoint oldWordTextOriginalCenter = oldWordTextView.center;
        
        WDWordTextWithoutCursorView *wordTextTransition = [[WDWordTextWithoutCursorView alloc] initWithFrame:oldWordTextOriginalFrame];
        wordTextTransition.backgroundColor = [UIColor clearColor];
        wordTextTransition.dataSource = self;
        wordTextTransition.alpha = 0.0;
        wordTextTransition.center = CGPointMake(wordTextTransition.center.x * -2.0, wordTextTransition.center.y);
        [self.wordTextWithoutCursorFontTransitionsView addObject:wordTextTransition];
        [self addSubview:wordTextTransition];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView animateWithDuration:1.25 animations:^{
            wordTextTransition.alpha = 1.0;
            wordTextTransition.center = oldWordTextOriginalCenter;
            oldWordTextView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.wordTextWithoutCursorView removeFromSuperview];
            self.wordTextWithoutCursorView = wordTextTransition;
            [self.wordTextWithoutCursorFontTransitionsView removeObject:wordTextTransition];
            self.wordTextWithCursorView.familyFont = [self.dataSource actualFamilyFontForWordRepresentationView:self];
        }];
    } else {
        self.wordTextWithCursorView.familyFont = [self.dataSource actualFamilyFontForWordRepresentationView:self];
    }
}

#pragma mark - Updates

- (void)updateCursorAnimation
{
    if (self.actualColorOfCursor != nil) {
        CGFloat colorComponents[4] = {0, 0, 0, 0};
        [self.actualColorOfCursor getRed:&colorComponents[0] green:&colorComponents[1] blue:&colorComponents[2] alpha:&colorComponents[3]];
        if ([WDUtils is:colorComponents[3] equalsTo:CURSOR_OPACITY]) {
            // El getter volvera a coger el valor original
            self.actualColorOfCursor = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:1.0];
        } else {
            self.actualColorOfCursor = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:CURSOR_OPACITY];
        }
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
            self.wordTextWithCursorView.frame = self.frame;
            [self insertSubview:self.wordTextWithCursorView atIndex:0];
            self.wordTextWithCursorView.alpha = 1.0;
        } else {
            [self setWordTextView:self.wordTextWithCursorView andQuitWordTextView:self.wordTextWithoutCursorView withDuration:duration];
        }
        self.wordTextWithCursorView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);        
        self.wordTextWithCursorView.familyFont = [self.dataSource actualFamilyFontForWordRepresentationView:self];
    }
}

- (void)setWithoutCursor:(CGFloat)duration;
{
    if ([WDUtils is:duration equalsTo:0.0]) {
        [self.wordTextWithCursorView removeFromSuperview];
        self.wordTextWithoutCursorView.frame = self.frame;
        [self insertSubview:self.wordTextWithoutCursorView atIndex:0];
        self.wordTextWithoutCursorView.alpha = 1.0;
    } else {
        [self setWordTextView:self.wordTextWithoutCursorView andQuitWordTextView:self.wordTextWithCursorView withDuration:duration];
    }
    
    self.wordTextWithoutCursorView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    self.wordTextWithoutCursorView.familyFont = [self.dataSource actualFamilyFontForWordRepresentationView:self];
    self.actualColorOfCursor = nil;
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
   
    const CGPoint startPointDraw = self.startDrawingPosition;
    const CGPoint endPointDraw = CGPointMake(self.bounds.size.width, startPointDraw.y);
    const CGFloat dashPattern[] = {2.0, 9.0};
    
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 1.5);
    CGFloat colorComponents[4] = {0, 0, 0, 0};
    [[self.dataSource actualSelectedWordAccessoriesWordRepresentation:self] getRed:&colorComponents[0] green:&colorComponents[1] blue:&colorComponents[2] alpha:&colorComponents[3]];
    //colorComponents[3] *= 0.5;
    CGContextSetStrokeColor(contextRef, colorComponents);
    CGContextMoveToPoint(contextRef, 0.0, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, self.bounds.size.width, endPointDraw.y);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
    
    [self.wordTextWithCursorView setNeedsDisplay];
    [self.wordTextWithoutCursorView setNeedsDisplay];
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
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]].length == 0) {
        [self.delegate keyboardDoneOnWordRepresentationView:self];
    } else if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        [self.delegate wordRepresentationView:self insertText:text];
    }
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

- (CGPoint)actualStartPointDrawingForWordTextView:(WDWordTextView *)wordTextView
{
    return self.startDrawingPosition;
}

- (BOOL)isInWritingModeForWordTextView:(WDWordTextView *)wordTextView
{
    return [self.dataSource isInWritingModeFoWordRepresentationView:self];
}

- (CGFloat)fontStartSize
{
    return [WDUtils isIPhone5Screen] ? FONT_START_SIZE * 1.15 : FONT_START_SIZE * 0.9;
}

- (UIColor *)actualCursorColorForWordTextView:(WDWordTextView *)wordTextView
{
    return self.actualColorOfCursor;
}

- (UIColor *)actualSelectedWordColorForWordTextView:(WDWordTextView *)wordTextView
{
    return [self.dataSource actualSelectedWordColorForWordRepresentation:self];
}

- (UIColor *)actualSelectedWordAccessoriesWordTextView:(WDWordTextView *)wordTextView
{
    return [self.dataSource actualSelectedWordAccessoriesWordRepresentation:self];
}

#pragma mark - Motion Events

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self.delegate shakeOnWordRepresentationView:self];
    }
}

@end
