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
#import "WDSettingsScreenViewController.h"
#import "WDDateSelectorView.h"
#import <QuartzCore/QuartzCore.h>

const NSUInteger DAYS_OF_WEEK = 7;
const NSUInteger WEEKS_MONTHS = 5;

@interface WDDashBoardViewController ()

@property (nonatomic, strong) NSDateComponents             *actualDate;
@property (weak, nonatomic) IBOutlet UILabel               *yearMonthLabel;
@property (weak, nonatomic) IBOutlet UIView                *daysOfTheWeekTitlesContainerView;
@property (weak, nonatomic) IBOutlet UIView                *daysOfTheMonthContainerView;
@property (nonatomic, strong) UITapGestureRecognizer       *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPresureGestureRecognizer;
@property (nonatomic, weak) WDDayMonthView                 *dayMonthPendingToRemove;
@property (weak, nonatomic) IBOutlet UIButton              *removeCancelButton;
@property (weak, nonatomic) IBOutlet UIButton              *settingsButton;
@property (nonatomic, strong) NSDate                       *normalizedRealTodayDate;
@property (nonatomic) BOOL                                 dateSelectorModeActive;

- (void)             createDayOfTheMonthsViews;

- (void)             configureDaysOfTheWeekTitles;
- (void)             configureMonthAndYearLabel;
- (void)             configureDayOfTheMonths;
- (void)             configureDayMonthViewWithoutWordMode:(WDDayMonthView *)dayMonthView;

- (NSDate *)         createNormalizedDateForDayMonthView:(WDDayMonthView *)dayMonthView;


- (NSUInteger)       findFirstWeekdayOfTheMonth;
- (NSUInteger)       findMaxDaysOfTheMonth;

- (void)             tapGestureRecognizerHandle:(UITapGestureRecognizer *)gestureRecognizer;
- (void)             longPresureGestureRecognizerHandle:(UILongPressGestureRecognizer *)gestureRecognizer;

- (WDDayMonthView *) findDayMonthViewForHitPoint:(CGPoint)hitPoint;
- (WDWord *)         findWordForHitPoint:(CGPoint)hitPoint;
- (WDWord *)         findWordForDayMonthView:(WDDayMonthView *)dayMonthView;

- (void)             exitRemoveDayMode;

- (void)             addGradientLayerToDayMonthView:(WDDayMonthView *)dayMonthView withWord:(WDWord *)word;
- (void)             removeGradientLayerOfDayMonthView:(WDDayMonthView *)dayMonthView;

@end

@implementation WDDashBoardViewController

#pragma mark - Synthesize

@synthesize actualDate                       = actualDate_;
@synthesize yearMonthLabel                   = yearMonthLabel_;
@synthesize daysOfTheWeekTitlesContainerView = daysOfTheWeekContainerView_;
@synthesize daysOfTheMonthContainerView      = daysOfTheMonthContainerView_;
@synthesize tapGestureRecognizer             = tapGestureRecognizer_;
@synthesize longPresureGestureRecognizer     = longPresureGestureRecognizer_;
@synthesize delegate                         = delegate_;
@synthesize normalizedRealTodayDate          = normalizedRealTodayDate_;
@synthesize dateSelectorModeActive           = dateSelectorModeActive_;

#pragma mar - Properties

-(void)setDateSelectorModeActive:(BOOL)dateSelectorModeActive
{
    if (dateSelectorModeActive != dateSelectorModeActive_) {
        dateSelectorModeActive_ = dateSelectorModeActive;
    }
}

-(NSDate *)normalizedRealTodayDate
{
    if (nil == normalizedRealTodayDate_) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *realTodayDate = [NSDate date];
        NSDateComponents *realTodayDateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:realTodayDate];
        normalizedRealTodayDate_ = [calendar dateFromComponents:realTodayDateComponents];
    }
    
    return normalizedRealTodayDate_;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
        longPresureGestureRecognizer_ = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPresureGestureRecognizerHandle:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.actualDate = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit fromDate:[NSDate date]];
    
    [self createDayOfTheMonthsViews];
    
    [self.daysOfTheMonthContainerView addGestureRecognizer:self.tapGestureRecognizer];
    [self.daysOfTheMonthContainerView addGestureRecognizer:self.longPresureGestureRecognizer];
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

- (void)removeGradientLayerOfDayMonthView:(WDDayMonthView *)dayMonthView
{
    for (CALayer *layerIt in dayMonthView.layer.sublayers) {
        if ([layerIt isKindOfClass:[CAGradientLayer class]]) {
            [layerIt removeFromSuperlayer];
            break;
        }
    }
}

- (void)addGradientLayerToDayMonthView:(WDDayMonthView *)dayMonthView withWord:(WDWord *)word
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    const CGFloat gradientWithMargin = dayMonthView.bounds.size.width * 0.1;
    gradient.frame = CGRectMake(gradientWithMargin, 0.0, dayMonthView.bounds.size.width
                                - gradientWithMargin * 2, dayMonthView.bounds.size.height);
    WDPalette *prevPalette = [[WDWordDiary sharedWordDiary] findPrevPaletteOfPalette:word.palette];
    WDPalette *prevPrevPalette = [[WDWordDiary sharedWordDiary] findPrevPaletteOfPalette:prevPalette];
    WDPalette *nextPalette = [[WDWordDiary sharedWordDiary] findNextPaletteOfPalette:word.palette];
    WDPalette *nextNextPalette = [[WDWordDiary sharedWordDiary] findNextPaletteOfPalette:nextPalette];
    gradient.colors = [NSArray arrayWithObjects:(id)[prevPrevPalette makeLightBackgroundColorObject].CGColor,
                       (id)[prevPalette makeLightBackgroundColorObject].CGColor,
                       (id)[word.palette makeLightBackgroundColorObject].CGColor,
                       (id)[nextPalette makeLightBackgroundColorObject].CGColor,
                       (id)[nextNextPalette makeLightBackgroundColorObject].CGColor,nil];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint = CGPointMake(0.5, 1.0);
    gradient.cornerRadius = 5.0;
    [dayMonthView.layer insertSublayer:gradient below:dayMonthView.dayOfMonthLabel.layer];
}

- (void)configureDayOfTheMonths
{
    const NSUInteger maxDayMonthViews = DAYS_OF_WEEK * WEEKS_MONTHS;
    const NSUInteger maxDaysOfTheMonth = [self findMaxDaysOfTheMonth];
    const NSUInteger firstWeekdayOfTheMonth = [self findFirstWeekdayOfTheMonth];
    
    for (NSUInteger dayMontViewIt = 0; dayMontViewIt < maxDayMonthViews; dayMontViewIt++) {
        const NSUInteger dayMonthViewIndex = dayMontViewIt + 1;
        WDDayMonthView *dayMonthViewIt = (WDDayMonthView *)[self.daysOfTheMonthContainerView viewWithTag:dayMonthViewIndex];
        
        [self removeGradientLayerOfDayMonthView:dayMonthViewIt];
        
        dayMonthViewIt.hidden = dayMonthViewIndex < firstWeekdayOfTheMonth || dayMonthViewIndex - (firstWeekdayOfTheMonth - 1) > maxDaysOfTheMonth;
        if (!dayMonthViewIt.hidden) {
            dayMonthViewIt.dayOfTheActualMonthIndex = dayMonthViewIndex - firstWeekdayOfTheMonth + 1;
            NSDateComponents *dateComponentOfDay = [self.actualDate copy];
            dateComponentOfDay.day = dayMonthViewIndex;
            WDWordDiary *wordDiary = [WDWordDiary sharedWordDiary];
            WDWord *wordOfCalendarDay = [wordDiary findWordWithDateComponents:dateComponentOfDay];
            if (wordOfCalendarDay && wordOfCalendarDay.word.length > 0) {
                dayMonthViewIt.backgroundColor = [UIColor clearColor];
                dayMonthViewIt.dayOfMonthLabel.textColor = [wordOfCalendarDay.palette makeWordColorObject];
                dayMonthViewIt.dayOfMonthLabel.text = [NSString stringWithFormat:@"%d", dayMonthViewIt.dayOfTheActualMonthIndex];
                /*
                dayMonthViewIt.initialLetterLabel.font = [UIFont fontWithName:wordOfCalendarDay.style.familyFont size:16];
                dayMonthViewIt.initialLetterLabel.textColor = [wordOfCalendarDay.palette makeWordColorObject];
                dayMonthViewIt.initialLetterLabel.text = [wordOfCalendarDay.word substringWithRange:NSMakeRange(0, 1)];
                 */
                
                [self addGradientLayerToDayMonthView:dayMonthViewIt withWord:wordOfCalendarDay];            
            } else {
                [self configureDayMonthViewWithoutWordMode:dayMonthViewIt];
            }
        }
    }
}

- (NSDate *)createNormalizedDateForDayMonthView:(WDDayMonthView *)dayMonthView
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *actualDayMonthViewDateComponents = [self.actualDate copy];
    actualDayMonthViewDateComponents.day = dayMonthView.dayOfTheActualMonthIndex;
    NSDate *normalizedActuayDayMonthViewDate = [calendar dateFromComponents:actualDayMonthViewDateComponents];

    return normalizedActuayDayMonthViewDate;
}

- (void)configureDayMonthViewWithoutWordMode:(WDDayMonthView *)dayMonthView
{
    NSDate *normalizedActuayDayMonthViewDate = [self createNormalizedDateForDayMonthView:dayMonthView];
    NSComparisonResult compareResult = [self.normalizedRealTodayDate compare:normalizedActuayDayMonthViewDate];
    const BOOL actualDayMonthViewAccesible = compareResult == NSOrderedDescending || compareResult == NSOrderedSame;
    dayMonthView.dayOfMonthLabel.textColor = actualDayMonthViewAccesible ? [UIColor lightGrayColor] : [UIColor darkGrayColor];
    dayMonthView.initialLetterLabel.text = @"";
    dayMonthView.backgroundColor = [UIColor blackColor];
    dayMonthView.layer.cornerRadius = 0.0;
    dayMonthView.dayOfTheActualMonthIndex = 0;
}

- (WDDayMonthView *)findDayMonthViewForHitPoint:(CGPoint)hitPoint
{
    WDDayMonthView *retDayMonthViewFound = nil;
    for (WDDayMonthView *dayMonthViewIt in self.daysOfTheMonthContainerView.subviews) {
        if ([dayMonthViewIt isKindOfClass:[WDDayMonthView class]] && CGRectContainsPoint(dayMonthViewIt.frame, hitPoint)) {
            retDayMonthViewFound = dayMonthViewIt;
            break;
        }
    }
    
    return retDayMonthViewFound;
}

- (WDWord *)findWordForDayMonthView:(WDDayMonthView *)dayMonthView
{
    WDWord *retWord = nil;
    if (!dayMonthView.hidden) {
        NSDateComponents *wordDateComponents = [self.actualDate copy];
        wordDateComponents.day = dayMonthView.dayOfTheActualMonthIndex;
        retWord = [[WDWordDiary sharedWordDiary] findWordWithDateComponents:wordDateComponents];
    }
    
    return retWord;
}

- (WDWord *)findWordForHitPoint:(CGPoint)hitPoint
{
    WDDayMonthView *dayMonthViewFound = [self findDayMonthViewForHitPoint:hitPoint];
    
    return [self findWordForDayMonthView:dayMonthViewFound];
}

- (void)exitRemoveDayMode
{
    self.dayMonthPendingToRemove.removeMode = NO;
    self.dayMonthPendingToRemove = nil;
    self.settingsButton.hidden = NO;
    self.removeCancelButton.hidden = YES;
}

#pragma mark - UITapGestureRecognizer

- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint hitPoint = [gestureRecognizer locationInView:self.daysOfTheMonthContainerView];
    WDWord *wordDayOfHitPoint = [self findWordForHitPoint:hitPoint];
    if (wordDayOfHitPoint) {
        if (self.dayMonthPendingToRemove) {
            WDWord *wordOfDayPendingToRemove = [self findWordForDayMonthView:self.dayMonthPendingToRemove];
            [self.delegate dashBoardViewController:self selectRemoveWord:wordOfDayPendingToRemove];
            [self configureDayMonthViewWithoutWordMode:self.dayMonthPendingToRemove];
            [self exitRemoveDayMode];
        } else {
            [self.delegate dashBoardViewController:self willDismissWithSelectedWord:wordDayOfHitPoint];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate dashBoardViewControllerDidDismiss:self];
            }];
        }
    }
}

- (void)longPresureGestureRecognizerHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (nil == self.dayMonthPendingToRemove && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint hitPoint = [gestureRecognizer locationInView:self.daysOfTheMonthContainerView];
        self.dayMonthPendingToRemove = [self findDayMonthViewForHitPoint:hitPoint];
        if (!self.dayMonthPendingToRemove.hidden) {
            self.dayMonthPendingToRemove.removeMode = YES;
            self.settingsButton.hidden = YES;
            self.removeCancelButton.hidden = NO;

        }
    }
}

#pragma mark - Control Events

- (IBAction)settingsButtonPressed:(id)sender
{
    WDSettingsScreenViewController *settingsScreenViewController = [[WDSettingsScreenViewController alloc] initWithNibName:nil bundle:nil];
    settingsScreenViewController.delegate = self;
    [self presentViewController:settingsScreenViewController animated:YES completion:nil];
}

- (IBAction)changeMonthYearButtonPressed:(id)sender
{
    self.dateSelectorModeActive = !self.dateSelectorModeActive;
}

- (IBAction)cancelRemoveDayMode:(id)sender
{
    [self exitRemoveDayMode];
}

#pragma mark - WDSettingsScreenViewControllerDelegate

- (void)wordWithIndex:(NSArray *)index removedFromSettingsScreenViewControllerRemoveAllEmptyWordDays:(WDSettingsScreenViewController *)settingsScreenViewController;
{
    [self.delegate wordWithIndex:index removedFromDashBoardViewControllerRemoveAllEmptyWordDays:self];
}

- (void)backgroundAnimationGradientSettingsUpdateFromSettingsScreenViewController:(WDSettingsScreenViewController *)settingsScreenViewController
{
    [self.delegate backgroundAnimationGradientSettingsUpdateFromDashBoardViewController:self];
}

#pragma mark - WDDateSelectorViewDataSource

#pragma mark - WDDateSelectorViewDelegate

@end
