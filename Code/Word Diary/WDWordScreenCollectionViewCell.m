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
#import <QuartzCore/QuartzCore.h>

@interface WDWordScreenCollectionViewCell()

@property (nonatomic, weak) IBOutlet    UILabel       *dateDayOfTheWeekLabel;
@property (nonatomic, weak) IBOutlet    UILabel       *dateDayAndMonthLabel;
@property (nonatomic, weak) IBOutlet    UILabel       *dateYearLabel;
@property (nonatomic, weak) IBOutlet    UILabel       *dayDiaryLabel;
@property (nonatomic, strong) CAGradientLayer         *gradientLayer;


- (void) setDateLabelOfWord:(WDWord *)word;
- (void) setDayDiaryLabelOfWord:(WDWord *)word;
- (void) setWordRepresentation:(WDWord *)word;

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
@synthesize gradientLayer                   = gradientLayer_;

#pragma mark - Properties

- (CAGradientLayer *)gradientLayer
{
    if (nil == gradientLayer_) {
        gradientLayer_ = [CAGradientLayer layer];
        [self.layer insertSublayer:gradientLayer_ atIndex:0];
    }
    return gradientLayer_;
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
    [self setDateLabelOfWord:word];
    [self setWordRepresentation:word];
    [self setDayDiaryLabelOfWord:word];
    
    [self setBackgroundColorOfWord:word];
    
    self.dateContainerView.alpha = 1.0;
    self.dayDiaryContainerView.alpha = 1.0;
}

- (void) setBackgroundColorOfWord:(WDWord *)word
{
    WDPalette *prevPalette = [[WDWordDiary sharedWordDiary] findPrevPaletteOfPalette:word.palette];
    WDPalette *nextPalette = [[WDWordDiary sharedWordDiary] findNextPaletteOfPalette:word.palette];
    NSLog(@"prev %@ center %@ next %@", prevPalette.idName, word.palette.idName, nextPalette.idName);
    self.gradientLayer.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    self.gradientLayer.colors = [[NSArray alloc] initWithObjects:(id)[prevPalette makeLightBackgroundColorObject].CGColor, (id)[word.palette makeLightBackgroundColorObject].CGColor, (id)[nextPalette makeLightBackgroundColorObject].CGColor, nil];
    self.gradientLayer.locations = [NSArray arrayWithObjects:@0.35F, @0.65F, @1.0F, nil];
    self.gradientLayer.startPoint = CGPointMake(0.5, 0.0);
    self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
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
