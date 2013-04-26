//
//  WDDashBoardViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDashBoardViewController.h"
#import "WDDayMonthView.h"
#import "WDWord.h"
#import "WDPalette.h"
#import "WDStyle.h"
#import "WDWordDiary.h"
#import "WDUtils.h"
#import <QuartzCore/QuartzCore.h>

const NSUInteger DAYS_OF_WEEK = 7;
const NSUInteger WEEKS_MONTHS = 5;

@interface WDDashBoardViewController ()

@property(nonatomic, strong) NSDateComponents       *actualDate;
@property (weak, nonatomic) IBOutlet UILabel        *yearMonthLabel;
@property (weak, nonatomic) IBOutlet UIView         *daysOfTheWeekTitlesContainerView;
@property (weak, nonatomic) IBOutlet UIView         *daysOfTheMonthContainerView;

- (void)       createDayOfTheMonthsViews;

- (void)       configureDaysOfTheWeekTitles;
- (void)       configureMonthAndYearLabel;
- (void)       configureDayOfTheMonths;

- (NSUInteger) findFirstWeekdayOfTheMonth;
- (NSUInteger) findMaxDaysOfTheMonth;

@end

@implementation WDDashBoardViewController

#pragma mark - Synthesize

@synthesize actualDate                       = actualDate_;
@synthesize yearMonthLabel                   = yearMonthLabel_;
@synthesize daysOfTheWeekTitlesContainerView = daysOfTheWeekContainerView_;
@synthesize daysOfTheMonthContainerView      = daysOfTheMonthContainerView_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.actualDate = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit fromDate:[NSDate date]];
    
    [self createDayOfTheMonthsViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureMonthAndYearLabel];
    [self configureDaysOfTheWeekTitles];
    [self configureDayOfTheMonths];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (void)createDayOfTheMonthsViews
{
    for (NSUInteger rowIt = 0; rowIt < WEEKS_MONTHS; rowIt++) {
        for (NSUInteger dayOfTheWeekIt = 0; dayOfTheWeekIt < DAYS_OF_WEEK; dayOfTheWeekIt++) {
            const NSUInteger indexMonthView = (rowIt * DAYS_OF_WEEK) + dayOfTheWeekIt + 1;
            CGRect monthViewFrame = CGRectMake(dayOfTheWeekIt == 0 ? 0 : 44.0 * dayOfTheWeekIt + 6.0,
                                               rowIt * 44.0,
                                               dayOfTheWeekIt == 0 || dayOfTheWeekIt == DAYS_OF_WEEK - 1 ? 50.0 : 44.0,
                                               44.0);
            WDDayMonthView *monthViewIt = [[WDDayMonthView alloc] initWithIndex:indexMonthView andFrame:monthViewFrame];
            monthViewIt.tag = indexMonthView;
            [self.daysOfTheMonthContainerView addSubview:monthViewIt];

        }
    }
}


- (void)configureDaysOfTheWeekTitles
{
    NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
    for (NSUInteger dayOfTheWeekTagIt = 1; dayOfTheWeekTagIt < 8; dayOfTheWeekTagIt++) {
        NSUInteger labelIndex = dayOfTheWeekTagIt + (firstWeekday - 1);
        if (labelIndex > 7) {
            labelIndex -= 7;
        }
        UILabel *dayTitleLabel = (UILabel *)[self.daysOfTheWeekTitlesContainerView viewWithTag:dayOfTheWeekTagIt];
        dayTitleLabel.text = [WDUtils stringFromWeekday:labelIndex];
        dayTitleLabel.text = [dayTitleLabel.text substringWithRange:NSMakeRange(0, 3)];
        dayTitleLabel.text = [dayTitleLabel.text lowercaseString];
    }
}

- (void)configureMonthAndYearLabel
{
    self.yearMonthLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TAG_DASHBOARDSCREEN_YEARMONTH_FORMATLABEL", @""), [WDUtils monthString:self.actualDate.month abreviateMode:NO], self.actualDate.year];
}

- (NSUInteger)findFirstWeekdayOfTheMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *firstDayDateComponents = [self.actualDate copy];
    firstDayDateComponents.year = 2013;
   // firstDayDateComponents.month = 2;
    firstDayDateComponents.day = 1;
    firstDayDateComponents.week = 1;
    NSDate *date = [calendar dateFromComponents:firstDayDateComponents];
    NSUInteger firstWeekDay = [calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:date];
    
    return firstWeekDay;
}

- (NSUInteger)findMaxDaysOfTheMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:self.actualDate];
    NSRange rangeDaysOfMonth = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return rangeDaysOfMonth.length;
}


- (void)configureDayOfTheMonths
{
    const NSUInteger maxDayMonthViews = DAYS_OF_WEEK * WEEKS_MONTHS;
    const NSUInteger maxDaysOfTheMonth = [self findMaxDaysOfTheMonth];
    const NSUInteger firstWeekdayOfTheMonth = [self findFirstWeekdayOfTheMonth];
    
    for (NSUInteger dayMontViewIt = 0; dayMontViewIt < maxDayMonthViews; dayMontViewIt++) {
        const NSUInteger dayMonthViewIndex = dayMontViewIt + 1;
        WDDayMonthView *dayMonthViewIt = (WDDayMonthView *)[self.daysOfTheMonthContainerView viewWithTag:dayMonthViewIndex];
        /*
        CALayer *gradientLayer = [dayMonthViewIt.layer.sublayers objectAtIndex:0];
        [gradientLayer removeFromSuperlayer];
        */
        dayMonthViewIt.hidden = dayMonthViewIndex < firstWeekdayOfTheMonth || dayMonthViewIndex - (firstWeekdayOfTheMonth - 1) > maxDaysOfTheMonth;
        if (!dayMonthViewIt.hidden) {
            NSDateComponents *dateComponentOfDay = [self.actualDate copy];
            dateComponentOfDay.day = dayMonthViewIndex;
            WDWordDiary *wordDiary = [WDWordDiary sharedWordDiary];
            WDWord *wordOfCalendarDay = [wordDiary findWordWithDateComponents:dateComponentOfDay];
            if (wordOfCalendarDay) {
                dayMonthViewIt.backgroundColor = [wordOfCalendarDay.palette makeLightBackgroundColorObject];
                dayMonthViewIt.dayOfMonthLabel.textColor = [wordOfCalendarDay.palette makeWordColorObject];
                dayMonthViewIt.dayOfMonthLabel.text = [NSString stringWithFormat:@"%d", dayMonthViewIndex - firstWeekdayOfTheMonth + 1];
                dayMonthViewIt.initialLetterLabel.font = [UIFont fontWithName:wordOfCalendarDay.style.familyFont size:16];
                dayMonthViewIt.initialLetterLabel.textColor = [wordOfCalendarDay.palette makeWordColorObject];
                dayMonthViewIt.initialLetterLabel.text = [wordOfCalendarDay.word substringWithRange:NSMakeRange(0, 1)];
                dayMonthViewIt.layer.cornerRadius = 2.0;
                dayMonthViewIt.layer.borderColor = [UIColor blackColor].CGColor;
                dayMonthViewIt.layer.borderWidth = 0.5;
                /*
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = dayMonthViewIt.bounds
                WDPalette *prevPalette = [wordDiary findNextPaletteOfPalette:wordOfCalendarDay.palette];
                WDPalette *nextPalette = [wordDiary findNextPaletteOfPalette:wordOfCalendarDay.palette];
                gradient.colors = [NSArray arrayWithObjects:(id)[prevPalette makeLightBackgroundColorObject].CGColor, (id)[wordOfCalendarDay.palette makeLightBackgroundColorObject].CGColor, (id)[nextPalette makeLightBackgroundColorObject].CGColor, nil];
                gradient.startPoint = CGPointMake(0.5, 0.0);
                gradient.endPoint = CGPointMake(0.5, 1.0);
                [dayMonthViewIt.layer insertSublayer:gradientLayer atIndex:0];
                */
            } else {
                dayMonthViewIt.dayOfMonthLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
                dayMonthViewIt.initialLetterLabel.text = @"";
                dayMonthViewIt.backgroundColor = [UIColor blackColor];
                dayMonthViewIt.layer.cornerRadius = 0.0;
            }
        }
    }
}


@end
