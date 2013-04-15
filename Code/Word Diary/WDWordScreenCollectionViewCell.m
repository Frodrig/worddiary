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

@interface WDWordScreenCollectionViewCell()

@property (weak, nonatomic) IBOutlet    UIView        *dateContainerView;
@property (nonatomic, weak) IBOutlet    UILabel       *dateDayOfTheWeekLabel;
@property (nonatomic, weak) IBOutlet    UILabel       *dateDayAndMonthLabel;
@property (nonatomic, weak) IBOutlet    UILabel       *dateYearLabel;
@property (weak, nonatomic) IBOutlet    UIView        *dayDiaryContainerView;
@property (nonatomic, weak) IBOutlet    UILabel       *dayDiaryLabel;


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
#pragma mark - SetWord

- (void)setWord:(WDWord *)word
{
    [self setDateLabelOfWord:word];
    [self setWordRepresentation:word];
    [self setDayDiaryLabelOfWord:word];
    
    self.contentView.backgroundColor = [UIColor colorWithHexadecimalValue:word.palette.backgroundColor withAlphaComponent:NO skipInitialCharacter:NO];
    
    self.dateContainerView.alpha = 1.0;
    self.dayDiaryContainerView.alpha = 1.0;
}

- (void)setDateLabelOfWord:(WDWord *)word
{
    NSDictionary *attributedTextProperties = @{
                                              NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:28.0],
                                              NSForegroundColorAttributeName: [UIColor colorWithHexadecimalValue:word.palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO],
                                              NSKernAttributeName: [NSNumber numberWithInt:2]};
    
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
                                                               NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:32.0],
                                                    NSForegroundColorAttributeName: [UIColor colorWithHexadecimalValue:word.palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO],
                                                               NSKernAttributeName: [NSNumber numberWithInt:6]}];
}

- (void) fadeInDecoratorText
{
    [UIView animateWithDuration:0.25 animations:^{
        self.dateContainerView.alpha = 1.0;
        self.dayDiaryContainerView.alpha = 1.0;
    }];
}
- (void) fadeOutDecoratorText
{
    [UIView animateWithDuration:1.0 animations:^{
        self.dateContainerView.alpha = 0.1;
        self.dayDiaryContainerView.alpha = 0.1;
    }];
}

@end
