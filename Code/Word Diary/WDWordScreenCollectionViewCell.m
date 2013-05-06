//
//  WDWordCollectionViewCell.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordScreenCollectionViewCell.h"
#import "WDWord.h"
#import "WDPalette.h"
#import "WDStyle.h"
#import "WDUtils.h"
#import "WDWordDiary.h"
#import "UIColor+hexColorCreation.h"
#import "CALayer+PauseResume.h"
#import <QuartzCore/QuartzCore.h>

@interface WDWordScreenCollectionViewCell()

@property (nonatomic, weak) IBOutlet    UILabel       *dateDayOfTheWeekLabel;
@property (nonatomic, weak) IBOutlet    UILabel       *dateDayAndMonthLabel;
@property (nonatomic, weak) IBOutlet    UILabel       *dateYearLabel;
@property (nonatomic, weak) IBOutlet    UILabel       *dayDiaryLabel;
@property (nonatomic, strong) CAGradientLayer         *gradientLayerBackgroundColor;
@property (nonatomic, strong) CAGradientLayer         *gradientLayerBorder;
@property (nonatomic) BOOL                            backgroundColorAnimationPaused;


- (void) setDateLabelOfWord:(WDWord *)word;
- (void) setDayDiaryLabelOfWord:(WDWord *)word;
- (void) setWordRepresentation:(WDWord *)word;

- (void) addBackgroundColorAnimation;

- (void) addBorderGradientLayer;

@end

@implementation WDWordScreenCollectionViewCell

#pragma mark - Synthesize

@synthesize dateContainerView               = dateContainerView_;
@synthesize dateDayOfTheWeekLabel           = dateDayOfTheWeekLabel_;
@synthesize dateDayAndMonthLabel            = dateDayAndMonthLabel_;
@synthesize dateYearLabel                   = dateYearLabel_;
@synthesize dayDiaryContainerView           = dayDiaryContainerView_;
@synthesize dayDiaryLabel                   = dayDiaryLabel_;
@synthesize wordRepresentationContainerView = wordRepresentationContainerView_;
@synthesize wordRepresentationView          = wordRepresentationView_;
@synthesize gradientLayerBackgroundColor    = gradientLayerBackgroundColor_;
@synthesize gradientLayerBorder             = gradientLayerBorder_;
@synthesize backgroundColorAnimationPaused  = backgroundColorAnimationPaused_;

#pragma mark - Properties

- (CAGradientLayer *)gradientLayerBackgroundColor
{
    if (nil == gradientLayerBackgroundColor_) {
        gradientLayerBackgroundColor_ = [CAGradientLayer layer];
        [self.layer insertSublayer:gradientLayerBackgroundColor_ atIndex:0];
    }
    return gradientLayerBackgroundColor_;
}

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
/*- (void)drawRect:(CGRect)rect
{
}
*/
/*
-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    // apply custom attributes...
    [super applyLayoutAttributes:layoutAttributes];
    
    [self.wordRepresentationView setNeedsDisplay]; // force drawRect:
}
*/

-(void) prepareForReuse
{
    [super prepareForReuse];
    
    [self.wordRepresentationView setNeedsDisplay];
}

#pragma mark - Setters

- (void)setWord:(WDWord *)word
{
    NSLog(@"setword");
    [self setDateLabelOfWord:word];
    [self setWordRepresentation:word];
    [self setDayDiaryLabelOfWord:word];
    
    [self refreshBackgroundColorOfWord:word];
    
    self.dateContainerView.alpha = 1.0;
    self.dayDiaryContainerView.alpha = 1.0;
    
    [self addBorderGradientLayer];
}

- (void) addBorderGradientLayer
{
    /*
    if (nil == self.gradientLayerBorder) {
        self.gradientLayerBorder = [CAGradientLayer layer];
        self.gradientLayerBorder.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        self.gradientLayerBorder.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.30].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.1].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.1].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.30].CGColor, nil];
        self.gradientLayerBorder.locations = [NSArray arrayWithObjects:@0.0F, @0.05F, @0.95F, @1.0f, nil];
        self.gradientLayerBorder.startPoint = CGPointMake(0.0, 0.5);
        self.gradientLayerBorder.endPoint = CGPointMake(1.0, 0.5);
    
        [self.layer insertSublayer:self.gradientLayerBorder above:self.gradientLayerBackgroundColor];
    }
     */
}

- (void)refreshBackgroundColorOfWord:(WDWord *)word
{
    WDPalette *prevPalette = [[WDWordDiary sharedWordDiary] findPrevPaletteOfPalette:word.palette];
    WDPalette *nextPalette = [[WDWordDiary sharedWordDiary] findNextPaletteOfPalette:word.palette];
    WDPalette *prevprevPalette = [[WDWordDiary sharedWordDiary] findPrevPaletteOfPalette:prevPalette];
    WDPalette *nextnextPalette = [[WDWordDiary sharedWordDiary] findNextPaletteOfPalette:nextPalette];
    
    self.gradientLayerBackgroundColor.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    self.gradientLayerBackgroundColor.colors = [[NSArray alloc] initWithObjects:(id)[prevprevPalette makeLightBackgroundColorObject].CGColor, (id)[prevPalette makeLightBackgroundColorObject].CGColor, (id)[word.palette makeLightBackgroundColorObject].CGColor, (id)[nextPalette makeLightBackgroundColorObject].CGColor, (id)[nextnextPalette makeLightBackgroundColorObject].CGColor, nil];
   // self.gradientLayerBackgroundColor.locations = [NSArray arrayWithObjects:@0.0F, @0.4F, @0.9F, nil];
    self.gradientLayerBackgroundColor.startPoint = CGPointMake(0.5, 0.0);
    self.gradientLayerBackgroundColor.endPoint = CGPointMake(0.5, 1.0);
    
    [self addBackgroundColorAnimation];
    
    // Update color de fechas, dia de diaria
    [self updateColorOfLabel:self.dateDayOfTheWeekLabel withColor:[word.palette makeWordColorObject]];
    [self updateColorOfLabel:self.dateDayAndMonthLabel withColor:[word.palette makeWordColorObject]];
    [self updateColorOfLabel:self.dateYearLabel withColor:[word.palette makeWordColorObject]];
    [self updateColorOfLabel:self.dayDiaryLabel withColor:[word.palette makeWordColorObject]];
}

- (void)addBackgroundColorAnimation
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SETTINGS_SCREEN_ACTIVATEBACKGROUNDGRADIENTANIM"]) {
        if (!self.backgroundColorAnimationPaused &&
            self.gradientLayerBackgroundColor.animationKeys.count == 0) {
            /*
             CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"locations"];
             anim.fromValue = self.gradientLayer.locations;
             anim.toValue = [NSArray arrayWithObjects:@0.05F, @0.85F, @1.0F, nil];
             anim.duration = 3.0;
             anim.removedOnCompletion = NO;
             anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
             anim.repeatCount = HUGE_VALF;
             anim.autoreverses = YES;
             [self.gradientLayer addAnimation:anim forKey:@"gradientAnimation"];
             */
            /*
             CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
             anim.fromValue = [NSNumber numberWithFloat:gradientLayer_.opacity];
             anim.toValue = [NSNumber numberWithFloat:0.9];
             anim.duration = 1.0;
             anim.removedOnCompletion = NO;
             anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
             anim.repeatCount = HUGE_VALF;
             anim.autoreverses = YES;
             [self.gradientLayer addAnimation:anim forKey:@"gradientAnimation"];
             */
            CAKeyframeAnimation *gradientAnimationStartPoint = [CAKeyframeAnimation animationWithKeyPath:@"startPoint"];
            [gradientAnimationStartPoint setValues:[NSArray arrayWithObjects:
                                                    [NSValue valueWithCGPoint:CGPointMake(0.5, 0.0)],
                                                    [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                                    [NSValue valueWithCGPoint:CGPointMake(0.5, 0.0)],
                                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 0.0)],
                                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 0.5)],
                                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                                    nil]];
            gradientAnimationStartPoint.duration = 5.0;
            gradientAnimationStartPoint.removedOnCompletion = NO;
            gradientAnimationStartPoint.calculationMode = kCAAnimationPaced;
            gradientAnimationStartPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            gradientAnimationStartPoint.repeatCount = HUGE_VALF;
            gradientAnimationStartPoint.autoreverses = YES;
            [self.gradientLayerBackgroundColor addAnimation:gradientAnimationStartPoint forKey:@"animateGradientChangeStartPoints"];
            
            
            CAKeyframeAnimation *gradientAnimationEndPoint = [CAKeyframeAnimation animationWithKeyPath:@"endPoint"];
            [gradientAnimationEndPoint setValues:[NSArray arrayWithObjects:
                                                  [NSValue valueWithCGPoint:CGPointMake(0.5, 1.0)],
                                                  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                                  [NSValue valueWithCGPoint:CGPointMake(0.5, 1.0)],
                                                  [NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)],
                                                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.5)],
                                                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                                  nil]];
            gradientAnimationEndPoint.duration = 5.0;
            gradientAnimationEndPoint.removedOnCompletion = NO;
            gradientAnimationEndPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            gradientAnimationEndPoint.calculationMode = kCAAnimationPaced;
            gradientAnimationEndPoint.repeatCount = HUGE_VALF;
            gradientAnimationEndPoint.autoreverses = YES;
            [self.gradientLayerBackgroundColor addAnimation:gradientAnimationEndPoint forKey:@"animateGradientChangeEndPoints"];
        }
    } else {
        [self.gradientLayerBackgroundColor removeAllAnimations];
    }
  }

- (void) pauseBackgroundColorAnimation
{
    self.backgroundColorAnimationPaused = YES;
    [self.gradientLayerBackgroundColor removeAllAnimations];
}

- (void) resumeBackgroundColorAnimation
{
    self.backgroundColorAnimationPaused = NO;
    [self addBackgroundColorAnimation];
}

- (void) updateColorOfLabel:(UILabel *)label withColor:(UIColor *)color
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [label.text length])];
    label.attributedText = attrString;
}

- (void)setDateLabelOfWord:(WDWord *)word
{
    NSDictionary *attributedTextProperties = @{
                                              NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:24.0],
                                              NSForegroundColorAttributeName: [word.palette makeWordColorObject],
                                              NSKernAttributeName: [NSNumber numberWithInt:6]};
    
    self.dateYearLabel.attributedText = [[NSAttributedString alloc] initWithString:[word yearAsString] attributes:attributedTextProperties];
  
    self.dateDayAndMonthLabel.attributedText = [[NSAttributedString alloc] initWithString:word.dayAndMonthAsString attributes:attributedTextProperties];
    
    NSString *dayOfTheWeekText = nil;
    NSUInteger daysSinceToday = [word daysSinceTodayDate];
    if (daysSinceToday == 0) {
        dayOfTheWeekText = [NSString stringWithFormat:@"%@", NSLocalizedString(@"TAG_TODAY", @"")];
    } else if (daysSinceToday == 1) {
        dayOfTheWeekText = [NSString stringWithFormat:@"%@", NSLocalizedString(@"TAG_YESTERDAY", @"")];
    } else {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *dateFromWordTimeInterval = [NSDate dateWithTimeIntervalSince1970:word.timeInterval];
        NSDateComponents *dateComponents = [calendar components:NSWeekdayCalendarUnit fromDate:dateFromWordTimeInterval];
        dayOfTheWeekText = [WDUtils stringFromWeekday:dateComponents.weekday];
    }
    self.dateDayOfTheWeekLabel.attributedText = [[NSAttributedString alloc] initWithString:dayOfTheWeekText attributes:attributedTextProperties];
}

- (void)setWordRepresentation:(WDWord *)word
{
}

- (void)setDayDiaryLabelOfWord:(WDWord *)word
{
    NSNumber *dayDiaryNumber = [NSNumber numberWithUnsignedInteger:[[WDWordDiary sharedWordDiary] findIndexPositionForWord:word] + 1];
    NSString *dayDiaryNumberNormalized = [WDUtils convertNumberToStringWithTwoDigitsMin:dayDiaryNumber];
    NSString *dayDiaryText = [NSString stringWithFormat:NSLocalizedString(@"TAG_DIARYDAY_LABEL", @""), dayDiaryNumberNormalized];
    self.dayDiaryLabel.attributedText = [[NSAttributedString alloc] initWithString:dayDiaryText
                                                                        attributes:@{
                                                               NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:28.0],
                                                    NSForegroundColorAttributeName: [word.palette makeWordColorObject],
                                                               NSKernAttributeName: [NSNumber numberWithInt:6]}];
}

- (void) fadeInDataAndDayText
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.35 animations:^{
        self.dateContainerView.alpha = 1.0;
        self.dayDiaryContainerView.alpha = 1.0;
    }];
}
- (void) fadeOutDataAndDayText
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:4.0 animations:^{
        self.dateContainerView.alpha = 0.1;
        self.dayDiaryContainerView.alpha = 0.1;
    }];
}

@end
