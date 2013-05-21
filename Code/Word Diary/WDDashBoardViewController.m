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
#import "WDInfoScreenViewController.h"
#import "WDDaysOfTheMonthContainerView.h"
#import "WDDaysOfTheWeekContainerView.h"
#import "WDChangeDateButtonContainerView.h"
#import "WDMonthYearView.h"
#import "WDMonthOfTheYearContainerGridView.h"
#import "WDMonthsOfTheYearContainerView.h"
#import <QuartzCore/QuartzCore.h>

const NSUInteger DAYS_OF_WEEK                             = 7;
const NSUInteger WEEKS_MONTHS                             = 5;
const CGFloat    DELAY_UPDATE_DAYMONTHS_NAVIGATION_EFFECT = 0;
const NSUInteger MAX_PENDING_REQUEST_TO_ATTEND            = 2;

@interface WDDashBoardViewController ()

@property (weak, nonatomic) IBOutlet UIView                             *datePannelViewContainer;
@property (nonatomic, strong) NSDateComponents                          *actualDate;
@property (nonatomic, strong) NSDateComponents                          *todayDate;
@property (weak, nonatomic) IBOutlet UILabel                            *yearMonthLabel;
@property (nonatomic, strong) UILabel                                   *wordsOfMonthLabel;
@property (weak, nonatomic) IBOutlet UIView                             *daysOfTheWeekTitlesContainerView;
@property (weak, nonatomic) IBOutlet UIView                             *daysOfTheMonthContainerView;
@property (nonatomic, strong) UITapGestureRecognizer                    *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer              *longPresureGestureRecognizer;
@property (nonatomic, weak) WDDayMonthView                              *dayMonthPendingToRemove;
@property (weak, nonatomic) IBOutlet UIButton                           *infoButton;
@property (nonatomic, strong) NSDate                                    *normalizedRealTodayDate;
@property (nonatomic) BOOL                                              dateSelectorModeActive;
@property (weak, nonatomic) IBOutlet UIButton                           *changeYearMonthButton;
@property (nonatomic, strong) CAGradientLayer                           *gradientLayer;
@property (weak, nonatomic) IBOutlet WDDaysOfTheMonthContainerView      *daysOfTheMonthGridView;
@property (weak, nonatomic) IBOutlet UIButton                           *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton                           *cancelButton;
@property (nonatomic, strong) UIPickerView                              *pickerView;
@property (weak, nonatomic) IBOutlet UIView                             *wordSlateContainerView;
@property (weak, nonatomic) IBOutlet UIButton                           *leftNavigationButton;
@property (weak, nonatomic) IBOutlet UIButton                           *rightNavigationButton;
@property (weak, nonatomic) IBOutlet UIImageView                        *removeStateImage;
@property (nonatomic) NSUInteger                                        pendingMonthNavigationRequest;
@property (nonatomic, strong) NSTimer                                   *minimumTimeNavigationPressTimer;
@property (weak, nonatomic) IBOutlet WDChangeDateButtonContainerView    *bottomContainerView;
@property (nonatomic) BOOL                                              canProcessNavigationUpdate;
@property (nonatomic, strong) UIView                                    *calendarModeViewContainer;
@property (nonatomic) NSNumber                                          *originalHeightOfDaysOfTheMonthContainerView;
@property (nonatomic) NSDateComponents                                  *backupDateBeforeChangeDateCalendarMode;
@property (nonatomic, strong) WDMonthsOfTheYearContainerView            *monthOfTheYearContainerView;

- (void)                createMonthsOfTheYearViews;
- (void)                configureMonthOfTheYearViews;

- (void)                createDayOfTheMonthsViews;
- (void)                removeEmptyWordsDays;
- (void)                configureDaysOfTheWeekTitles;
- (void)                configureMonthAndYearLabel;
- (void)                configureDayOfTheMonths:(BOOL)inmediate;
- (void)                vinculeGradientsToDaysWithWords:(BOOL)inmediate;
- (void)                configureDayMonthViewWithoutWordMode:(WDDayMonthView *)dayMonthView;

- (NSDate *)            createNormalizedDateForDayMonthView:(WDDayMonthView *)dayMonthView;

- (NSUInteger)          findFirstWeekdayOfTheMonth;
- (NSUInteger)          findMaxDaysOfTheMonth;

- (void)                tapGestureRecognizerHandle:(UITapGestureRecognizer *)gestureRecognizer;
- (void)                longPresureGestureRecognizerHandle:(UILongPressGestureRecognizer *)gestureRecognizer;

- (WDDayMonthView *)    findDayMonthViewForHitPoint:(CGPoint)hitPoint;
- (WDWord *)            findWordForHitPoint:(CGPoint)hitPoint;
- (WDWord *)            findWordForDayMonthView:(WDDayMonthView *)dayMonthView;
- (NSDateComponents *)  findDateComponentsForDayMonthView:(WDDayMonthView *)dayMonthView;

- (void)                exitRemoveDayMode;

- (BOOL)                logicChangeYearMonthWithSelectedDateComponents:(NSDateComponents *)dateComponents;
- (void)                exitChangeYearMonthModeWithSelectedDateComponents:(NSDateComponents *)dateComponents;

- (void)                addGradientLayerToDayMonthView:(WDDayMonthView *)dayMonthView withWord:(WDWord *)word inmediate:(BOOL)inmediate;
- (void)                removeGradientLayerOfDayMonthView:(WDDayMonthView *)dayMonthView;

- (void)                applicationWillResignActive:(NSNotification *)notification;
- (void)                applicationDidEnterBackground:(NSNotification *)notification;
- (void)                applicationWillEnterForeground:(NSNotification *)notification;
- (void)                applicationDidBecomeActive:(NSNotification *)notification;
- (void)                applicationWillTerminate:(NSNotification *)notification;

- (void)                significantTimeChange:(NSNotification *)notification;

- (void)                updateYearMonthData:(NSNumber *)rightDirection;

- (void)                launchAddGradientToWordDaysTimer;
- (void)                minimumTimeNavigationPressTimerHandle:(NSTimer *)timer;

- (void)                setNumberOfWordsOfTheMonth:(BOOL)inmediate;
- (NSUInteger)          findNumberOfWordsOfActualMonth;

@end

@implementation WDDashBoardViewController

#pragma mark - Synthesize

@synthesize datePannelViewContainer                     = datePannelViewContainer_;
@synthesize actualDate                                  = actualDate_;
@synthesize yearMonthLabel                              = yearMonthLabel_;
@synthesize wordsOfMonthLabel                           = wordsOfMonthLabel_;
@synthesize daysOfTheWeekTitlesContainerView            = daysOfTheWeekContainerView_;
@synthesize daysOfTheMonthContainerView                 = daysOfTheMonthContainerView_;
@synthesize tapGestureRecognizer                        = tapGestureRecognizer_;
@synthesize longPresureGestureRecognizer                = longPresureGestureRecognizer_;
@synthesize delegate                                    = delegate_;
@synthesize dataSource                                  = dataSource_;
@synthesize normalizedRealTodayDate                     = normalizedRealTodayDate_;
@synthesize dateSelectorModeActive                      = dateSelectorModeActive_;
@synthesize todayDate                                   = todayDate_;
@synthesize changeYearMonthButton                       = changeYearMonthButton_;
@synthesize gradientLayer                               = gradientLayer_;
@synthesize daysOfTheMonthGridView                      = daysOfTheMonthGridView_;
@synthesize acceptButton                                = acceptButton_;
@synthesize cancelButton                                = cancelButton_;
@synthesize pickerView                                  = pickerView_;
@synthesize infoButton                                  = infoButton_;
@synthesize wordSlateContainerView                      = wordSlateContainerView_;
@synthesize leftNavigationButton                        = leftNavigationButton_;
@synthesize rightNavigationButton                       = rightNavigationButton_;
@synthesize removeStateImage                            = removeStateImage_;
@synthesize pendingMonthNavigationRequest               = pendingMonthNavigationRequest_;
@synthesize minimumTimeNavigationPressTimer             = minimumTimeNavigationPressTimer_;
@synthesize bottomContainerView                         = bottomContainerView_;
@synthesize canProcessNavigationUpdate                  = canProcessNavigationUpdate_;
@synthesize calendarModeViewContainer                   = calendarModeViewContainer_;
@synthesize originalHeightOfDaysOfTheMonthContainerView = originalHeightOfDaysOfTheMonthContainerView_;
@synthesize backupDateBeforeChangeDateCalendarMode      = backupDateBeforeChangeDateCalendarMode_;
@synthesize monthOfTheYearContainerView                 = monthOfTheYearContainerView_;


#pragma mar - Properties

- (NSDateComponents *)todayDate
{
    if (todayDate_ == nil) {
        todayDate_ = [[WDWordDiary sharedWordDiary].currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    }
    
    return todayDate_;
}

-(NSDate *)normalizedRealTodayDate
{
    if (nil == normalizedRealTodayDate_) {
        NSDate *realTodayDate = [NSDate date];
        NSDateComponents *realTodayDateComponents = [[WDWordDiary sharedWordDiary].currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:realTodayDate];
        normalizedRealTodayDate_ = [[WDWordDiary sharedWordDiary].currentCalendar dateFromComponents:realTodayDateComponents];
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
        canProcessNavigationUpdate_ = YES;
        
        tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
        longPresureGestureRecognizer_ = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPresureGestureRecognizerHandle:)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(significantTimeChange:) name:UIApplicationSignificantTimeChangeNotification object:nil];
        
        pendingMonthNavigationRequest_ = 0;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.actualDate = [self.dataSource dateComponentsFromWordDaySelectedForDashBoardViewController:self];
    self.daysOfTheMonthGridView.gridView.alpha = 0.5;
    
    [self createDayOfTheMonthsViews];
    
    [self.daysOfTheMonthContainerView addGestureRecognizer:self.tapGestureRecognizer];
    [self.daysOfTheMonthContainerView addGestureRecognizer:self.longPresureGestureRecognizer];
    
    self.datePannelViewContainer.backgroundColor = [UIColor colorWithWhite:0.16 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self configureMonthAndYearLabel];
    [self configureDaysOfTheWeekTitles];
    [self configureDayOfTheMonths:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (nil == self.originalHeightOfDaysOfTheMonthContainerView) {
        self.originalHeightOfDaysOfTheMonthContainerView = [NSNumber numberWithFloat:self.daysOfTheMonthContainerView.frame.size.height];
    }

    if (self.wordsOfMonthLabel == nil) {
        CGRect wordSlateBounds = CGRectMake(0.0, 0.0, self.wordSlateContainerView.bounds.size.width, self.bottomContainerView.frame.origin.y - (self.daysOfTheMonthContainerView.frame.origin.y + self.daysOfTheMonthContainerView.frame.size.height));
        self.wordSlateContainerView.bounds = wordSlateBounds;
        self.wordsOfMonthLabel = [[UILabel alloc] initWithFrame:wordSlateBounds];
        self.wordsOfMonthLabel.minimumScaleFactor = 0.5;
        self.wordsOfMonthLabel.numberOfLines = 2;
        self.wordsOfMonthLabel.adjustsFontSizeToFitWidth = YES;
        self.wordsOfMonthLabel.adjustsLetterSpacingToFitWidth = NO;
        self.wordsOfMonthLabel.textAlignment = NSTextAlignmentCenter;
        self.wordsOfMonthLabel.backgroundColor = [UIColor clearColor];
        [self.wordSlateContainerView addSubview:self.wordsOfMonthLabel];
        self.wordsOfMonthLabel.alpha = 0.0;
    }

    [self setNumberOfWordsOfTheMonth:NO];

    [self removeEmptyWordsDays];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (NSUInteger)findNumberOfWordsOfActualMonth
{
    const NSUInteger maxDayMonthViews = DAYS_OF_WEEK * WEEKS_MONTHS;
    const NSUInteger firstWeekdayOfTheMonth = [self findFirstWeekdayOfTheMonth];
    NSUInteger numberOfWords = 0;
    for (NSUInteger dayMontViewIterator = 0; dayMontViewIterator < maxDayMonthViews; dayMontViewIterator++) {
        const NSUInteger dayMonthViewIndex = dayMontViewIterator + 1;
        WDDayMonthView *dayMonthViewIt = (WDDayMonthView *)[self.daysOfTheMonthContainerView viewWithTag:dayMonthViewIndex];
        if (!dayMonthViewIt.hidden) {
            dayMonthViewIt.dayOfTheActualMonthIndex = dayMonthViewIndex - firstWeekdayOfTheMonth + 1;
            NSDateComponents *dateComponentOfDay = [[NSDateComponents alloc] init];
            dateComponentOfDay.year = self.actualDate.year;
            dateComponentOfDay.month = self.actualDate.month;
            dateComponentOfDay.day = dayMonthViewIt.dayOfTheActualMonthIndex;
            WDWord *word = [[WDWordDiary sharedWordDiary] findWordWithDateComponents:dateComponentOfDay];
            if (word.word.length > 0) {
                ++numberOfWords;
            }
        }
    }
    
    return numberOfWords;
}

- (void)setNumberOfWordsOfTheMonth:(BOOL)inmediate
{
    const NSUInteger numberOfWords = [self findNumberOfWordsOfActualMonth];
    self.wordsOfMonthLabel.attributedText = [[NSAttributedString alloc]
                                             initWithString:[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(numberOfWords == 1 ? @"TAG_DASHBOARDSCREEN_WORDCOUNTNAME_SINGULAR" : @"TAG_DASHBOARDSCREEN_WORDCOUNTNAME_PLURAL", @""), [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithInteger:numberOfWords]]]
                                             attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:[WDUtils is568Screen] ? 34 : 24],
                                             NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                             NSKernAttributeName: [NSNumber numberWithInteger:5.0]}];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:inmediate ? 0.0 : 2 animations:^{
        self.wordsOfMonthLabel.alpha = numberOfWords == 0 ? 0.2 : 1.0;
    }];
}

- (void)launchAddGradientToWordDaysTimer
{
    if (self.minimumTimeNavigationPressTimer) {
        [self.minimumTimeNavigationPressTimer invalidate];
    }
    
    self.minimumTimeNavigationPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(minimumTimeNavigationPressTimerHandle:) userInfo:nil repeats:NO];
}

- (void)minimumTimeNavigationPressTimerHandle:(NSTimer *)timer
{
    self.minimumTimeNavigationPressTimer = nil;
    [self vinculeGradientsToDaysWithWords:NO];
}

- (void)removeEmptyWordsDays
{
    NSArray *indexWords = [[WDWordDiary sharedWordDiary] removeAllDaysWithoutWord];
    if (indexWords.count > 0) {
        [self.delegate removeSectionsWithEmptyWordsFromDashBoardViewController:self];
    }
}

- (void)createDayOfTheMonthsViews
{
    for (NSUInteger rowIt = 0; rowIt < WEEKS_MONTHS; rowIt++) {
        for (NSUInteger dayOfTheWeekIt = 0; dayOfTheWeekIt < DAYS_OF_WEEK; dayOfTheWeekIt++) {
            const NSUInteger indexMonthView = (rowIt * DAYS_OF_WEEK) + dayOfTheWeekIt + 1;
            CGRect monthViewFrame = CGRectMake(dayOfTheWeekIt == 0 ? 0 : 50 + 44.0 * (dayOfTheWeekIt - 1),
                                               rowIt * 44.0,
                                               (dayOfTheWeekIt == 0 || dayOfTheWeekIt == DAYS_OF_WEEK - 1) ? 50.0 : 44.0,
                                               44.0);
            WDDayMonthView *monthViewIt = [[WDDayMonthView alloc] initWithIndex:indexMonthView andFrame:monthViewFrame];
            monthViewIt.tag = indexMonthView;
            [self.daysOfTheMonthContainerView insertSubview:monthViewIt belowSubview:self.daysOfTheMonthGridView];
        }
    }
}

- (void)configureDaysOfTheWeekTitles
{
    NSUInteger firstWeekday = [[WDWordDiary sharedWordDiary].currentCalendar firstWeekday];
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
    if (self.dateSelectorModeActive) {
        self.yearMonthLabel.text = [NSString stringWithFormat:@"%d", self.actualDate.year];
    } else {
        self.yearMonthLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TAG_DASHBOARDSCREEN_YEARMONTH_FORMATLABEL", @""), [WDUtils monthString:self.actualDate.month abreviateMode:NO], self.actualDate.year];
    }
}

- (void)vinculeGradientsToDaysWithWords:(BOOL)inmediate
{
    const NSUInteger maxDayMonthViews = DAYS_OF_WEEK * WEEKS_MONTHS;
    const NSUInteger firstWeekdayOfTheMonth = [self findFirstWeekdayOfTheMonth];
    
    for (NSUInteger dayMontViewIterator = 0; dayMontViewIterator < maxDayMonthViews; dayMontViewIterator++) {
        const NSUInteger dayMonthViewIndex = dayMontViewIterator + 1;
        WDDayMonthView *dayMonthViewIt = (WDDayMonthView *)[self.daysOfTheMonthContainerView viewWithTag:dayMonthViewIndex];
        if (!dayMonthViewIt.hidden) {
            dayMonthViewIt.dayOfTheActualMonthIndex = dayMonthViewIndex - firstWeekdayOfTheMonth + 1;
            NSDateComponents *dateComponentOfDay = [self.actualDate copy];
            dateComponentOfDay.day = dayMonthViewIt.dayOfTheActualMonthIndex;
            WDWordDiary *wordDiary = [WDWordDiary sharedWordDiary];
            WDWord *wordOfCalendarDay = [wordDiary findWordWithDateComponents:dateComponentOfDay];
            if (wordOfCalendarDay && wordOfCalendarDay.word.length > 0) {
                [self addGradientLayerToDayMonthView:dayMonthViewIt withWord:wordOfCalendarDay inmediate:inmediate];
                [dayMonthViewIt.dayOfMonthLabel setTextColor:[wordOfCalendarDay.palette makeWordColorObject]];
            }
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:inmediate ? 0.0 : 0.5 + (float)rand()/((float)RAND_MAX/0.75) animations:^{
                dayMonthViewIt.dayOfMonthLabel.alpha = 1;
            }];
        }
    }
    
    [self performSelector:@selector(setCanProcessNavigationUpdate:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.25];
    [self setNumberOfWordsOfTheMonth:inmediate];
    if (![WDUtils is:0.5 equalsTo:self.daysOfTheMonthGridView.gridView.alpha]) {
        self.daysOfTheMonthGridView.gridView.alpha = 0.5;
        [self.daysOfTheMonthGridView performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.25];
    }
}

- (NSUInteger)findFirstWeekdayOfTheMonth
{
    NSDateComponents *firstDayDateComponents = [self.actualDate copy];
    firstDayDateComponents.year = 2013;
    firstDayDateComponents.day = 1;
    firstDayDateComponents.week = 1;
    NSDate *date = [[WDWordDiary sharedWordDiary].currentCalendar dateFromComponents:firstDayDateComponents];
    NSUInteger firstWeekDay = [[WDWordDiary sharedWordDiary].currentCalendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:date];
    
    return firstWeekDay;
}

- (NSUInteger)findMaxDaysOfTheMonth
{
    NSDate *date = [[WDWordDiary sharedWordDiary].currentCalendar dateFromComponents:self.actualDate];
    NSRange rangeDaysOfMonth = [[WDWordDiary sharedWordDiary].currentCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
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

- (void)addGradientLayerToDayMonthView:(WDDayMonthView *)dayMonthView withWord:(WDWord *)word inmediate:(BOOL)inmediate
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(4.0, 4.0, 36.0, 36.0);
    if (dayMonthView.bounds.size.width > 44.0) {
        gradient.frame = CGRectMake(7.0, 4.0, 36.0, 36.0);
    }
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
    gradient.borderColor = [UIColor colorWithWhite:0.0 alpha:1].CGColor;
    gradient.borderWidth = 1.5;
    gradient.opacity = inmediate ? 1.0 : 0.0;
    [dayMonthView.layer addSublayer:gradient];
    [dayMonthView bringSubviewToFront:dayMonthView.dayOfMonthLabel];
    if (!inmediate) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration = (float)rand()/((float)RAND_MAX/2.35);
        opacityAnimation.removedOnCompletion = YES;
        opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
        opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [gradient addAnimation:opacityAnimation forKey:@"opacity"];
        gradient.opacity = 1.0;
    }
}

- (void)configureDayOfTheMonths:(BOOL)inmediate
{
    const NSUInteger maxDayMonthViews = DAYS_OF_WEEK * WEEKS_MONTHS;
    const NSUInteger maxDaysOfTheMonth = [self findMaxDaysOfTheMonth];
    const NSUInteger firstWeekdayOfTheMonth = [self findFirstWeekdayOfTheMonth];

    self.wordsOfMonthLabel.alpha = 0.5;
    
    for (NSUInteger dayMontViewIterator = 0; dayMontViewIterator < maxDayMonthViews; dayMontViewIterator++) {
        const NSUInteger dayMonthViewIndex = dayMontViewIterator + 1;
        WDDayMonthView *dayMonthViewIt = (WDDayMonthView *)[self.daysOfTheMonthContainerView viewWithTag:dayMonthViewIndex];
        
        [self removeGradientLayerOfDayMonthView:dayMonthViewIt];

        dayMonthViewIt.hidden = dayMonthViewIndex < firstWeekdayOfTheMonth || dayMonthViewIndex - (firstWeekdayOfTheMonth - 1) > maxDaysOfTheMonth;
        if (!dayMonthViewIt.hidden) {
            dayMonthViewIt.dayOfTheActualMonthIndex = dayMonthViewIndex - firstWeekdayOfTheMonth + 1;
            NSDateComponents *dateComponentOfDay = [[NSDateComponents alloc] init];
            dateComponentOfDay.year = self.actualDate.year;
            dateComponentOfDay.month = self.actualDate.month;
            dateComponentOfDay.day = dayMonthViewIt.dayOfTheActualMonthIndex;
            WDWordDiary *wordDiary = [WDWordDiary sharedWordDiary];
            WDWord *wordOfCalendarDay = [wordDiary findWordWithDateComponents:dateComponentOfDay];
            dayMonthViewIt.backgroundColor = [UIColor clearColor];
            dayMonthViewIt.dayOfMonthLabel.textColor = [wordOfCalendarDay.palette makeWordColorObject];
            dayMonthViewIt.dayOfMonthLabel.text = [NSString stringWithFormat:@"%d", dayMonthViewIt.dayOfTheActualMonthIndex];
            [self configureDayMonthViewWithoutWordMode:dayMonthViewIt];
            [NSObject cancelPreviousPerformRequestsWithTarget:dayMonthViewIt.dayOfMonthLabel];
        }
    }

    if (inmediate) {
        [self vinculeGradientsToDaysWithWords:inmediate];
    } else {
        [self launchAddGradientToWordDaysTimer];
    }
}

- (NSDate *)createNormalizedDateForDayMonthView:(WDDayMonthView *)dayMonthView
{
    NSDateComponents *actualDayMonthViewDateComponents = [self.actualDate copy];
    actualDayMonthViewDateComponents.day = dayMonthView.dayOfTheActualMonthIndex;
    NSDate *normalizedActuayDayMonthViewDate = [[WDWordDiary sharedWordDiary].currentCalendar dateFromComponents:actualDayMonthViewDateComponents];

    return normalizedActuayDayMonthViewDate;
}

- (void)configureDayMonthViewWithoutWordMode:(WDDayMonthView *)dayMonthView
{
    NSDate *normalizedActuayDayMonthViewDate = [self createNormalizedDateForDayMonthView:dayMonthView];
    NSComparisonResult compareResult = [self.normalizedRealTodayDate compare:normalizedActuayDayMonthViewDate];
    const BOOL actualDayMonthViewAccesible = compareResult == NSOrderedDescending || compareResult == NSOrderedSame;
    dayMonthView.dayOfMonthLabel.textColor = actualDayMonthViewAccesible ? [UIColor lightGrayColor] : [UIColor darkGrayColor];
    dayMonthView.backgroundColor = [UIColor clearColor];
    [self removeGradientLayerOfDayMonthView:dayMonthView];
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

- (NSDateComponents *)findDateComponentsForDayMonthView:(WDDayMonthView *)dayMonthView
{
    NSDateComponents *retDateComponents = nil;
    if (!dayMonthView.hidden) {
        retDateComponents = [self.actualDate copy];
        retDateComponents.day = dayMonthView.dayOfTheActualMonthIndex;
    }
    
    return retDateComponents;
}

- (WDWord *)findWordForDayMonthView:(WDDayMonthView *)dayMonthView
{
    WDWord *retWord = nil;
    NSDateComponents *wordDateComponents = [self findDateComponentsForDayMonthView:dayMonthView];
    if (wordDateComponents) {
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
    UILabel *selectedWordLabel = (UILabel *)[self.wordSlateContainerView viewWithTag:100];
    
    [UIView animateWithDuration:0.55 animations:^{
        self.acceptButton.alpha = self.cancelButton.alpha = 0.0;
        selectedWordLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.acceptButton.hidden = self.cancelButton.hidden = YES;
        self.removeStateImage.hidden = YES;
        self.changeYearMonthButton.hidden = NO;
        [self setNumberOfWordsOfTheMonth:YES];
        self.wordsOfMonthLabel.hidden = NO;
        self.infoButton.enabled = self.leftNavigationButton.enabled = self.rightNavigationButton.enabled = self.changeYearMonthButton.enabled = YES;
        [selectedWordLabel removeFromSuperview];
    }];
}

- (BOOL)logicChangeYearMonthWithSelectedDateComponents:(NSDateComponents *)dateComponents
{
    const BOOL logicChange = dateComponents != nil && (self.actualDate.year != dateComponents.year || self.actualDate.month != dateComponents.month || self.actualDate.day != dateComponents.day);
    if (logicChange) {
        self.actualDate.year = dateComponents.year;
        self.actualDate.month = dateComponents.month;
        self.actualDate.day = dateComponents.day;
        self.actualDate.week = dateComponents.week;
    }
    
    return logicChange;
}

- (void)exitChangeYearMonthModeWithSelectedDateComponents:(NSDateComponents *)dateComponents
{
    NSAssert(self.dateSelectorModeActive, @"Deberia de estar activo el modo de seleccion de fecha manual");
    
    self.dateSelectorModeActive = NO;
    
    const BOOL logicChange = [self logicChangeYearMonthWithSelectedDateComponents:dateComponents];
    if (logicChange) {
        [self configureDayOfTheMonths:YES];
    }
    
    [UIView animateWithDuration:0.55 animations:^{
        self.cancelButton.alpha = self.acceptButton.alpha = 0.0;
        self.yearMonthLabel.alpha = 0.0;
        self.pickerView.alpha = 0;
    } completion:^(BOOL finished) {
        [self configureMonthAndYearLabel];
        self.acceptButton.hidden = self.cancelButton.hidden = YES;
        [self.pickerView removeFromSuperview];
        self.pickerView = nil;
        [UIView animateWithDuration:0.5 animations:^{
            self.yearMonthLabel.alpha = 1.0;
            for (UIView *viewIt in self.daysOfTheWeekTitlesContainerView.subviews) {
                if ([viewIt isKindOfClass:[UILabel class]]) {
                    viewIt.alpha = 1.0;
                }
            }
            for (UIView *viewIt in self.daysOfTheMonthContainerView.subviews) {
                if ([viewIt isKindOfClass:[WDDayMonthView class]]) {
                    viewIt.alpha = 1.0;
                }
            }
            self.leftNavigationButton.alpha = self.rightNavigationButton.alpha = 1.0;
            [self setNumberOfWordsOfTheMonth:NO];
        } completion:^(BOOL finished) {
            self.changeYearMonthButton.enabled = YES;
            self.infoButton.enabled = YES;
        }];
    }];
}

- (void)createMonthsOfTheYearViews
{
    if (nil == self.monthOfTheYearContainerView) {
        self.monthOfTheYearContainerView = [[WDMonthsOfTheYearContainerView alloc]
                                            initWithFrame:CGRectMake(self.daysOfTheMonthContainerView.frame.origin.x,
                                                                     self.daysOfTheMonthContainerView.frame.origin.y,
                                                                    self.daysOfTheMonthContainerView.frame.size.width,
                                                                    self.daysOfTheMonthContainerView.frame.size.height + (self.bottomContainerView.frame.origin.y - (self.daysOfTheMonthContainerView.frame.origin.y + self.daysOfTheMonthContainerView.frame.size.height)))];
        const NSUInteger maxRows = 4;
        const NSUInteger maxColumns = 3;
        const CGFloat monthYearViewWidth = self.monthOfTheYearContainerView.bounds.size.width / maxColumns;
        const CGFloat monthYearViewHeight = self.monthOfTheYearContainerView.bounds.size.height / maxRows;
        for (NSUInteger rowIt = 0; rowIt < maxRows; rowIt++) {
            for (NSUInteger columnIt = 0; columnIt < maxColumns; columnIt++) {
                CGRect monthOfTheYearRect = CGRectMake(columnIt * monthYearViewWidth,
                                                       rowIt * monthYearViewHeight,
                                                       monthYearViewWidth,
                                                       monthYearViewHeight);
                WDMonthYearView *monthOfTheYearView = [[WDMonthYearView alloc]
                                                       initWithFrame:monthOfTheYearRect
                                                       andLabel:[WDUtils monthString:rowIt * maxColumns + columnIt + 1 abreviateMode:YES]];
                NSLog(@"%@ %d", NSStringFromCGRect(monthOfTheYearRect), rowIt * maxColumns + columnIt + 1);
                [self.monthOfTheYearContainerView addSubview:monthOfTheYearView];
            }
        }
    }
    
    [self.datePannelViewContainer addSubview:self.monthOfTheYearContainerView];
    self.monthOfTheYearContainerView.alpha = 0.0;
   // self.monthOfTheYearContainerView.backgroundColor = [UIColor clearColor];
}

- (void)configureMonthOfTheYearViews
{
    NSUInteger indexMonth = 1;
    for (UIView *monthYearViewIt in self.monthOfTheYearContainerView.subviews) {
        if ([monthYearViewIt isKindOfClass:[WDMonthYearView class]]) {
            WDMonthYearView *monthYearView = (WDMonthYearView *)monthYearViewIt;
            monthYearView.accesible = self.actualDate.year < self.todayDate.year ? YES : indexMonth <= self.todayDate.month;
            monthYearView.drawContentDot = [[WDWordDiary sharedWordDiary] findNumberOfWordsInMonth:indexMonth ofYear:self.actualDate.year];
            [monthYearView setNeedsDisplay];
            indexMonth++;
        }
    }
}

#pragma mark - UITapGestureRecognizer

- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    if (!self.dateSelectorModeActive && nil == self.dayMonthPendingToRemove) {
        CGPoint hitPoint = [gestureRecognizer locationInView:self.daysOfTheMonthContainerView];
        WDWord *wordDayOfHitPoint = [self findWordForHitPoint:hitPoint];
        if (nil == wordDayOfHitPoint) {
            WDDayMonthView *dayMonthViewFound = [self findDayMonthViewForHitPoint:hitPoint];
            NSDateComponents *dateComponentsOfView = [self findDateComponentsForDayMonthView:dayMonthViewFound];
            if (dateComponentsOfView) {
                BOOL validDay = dateComponentsOfView.year < self.todayDate.year;
                if (!validDay) {
                    validDay = dateComponentsOfView.month < self.todayDate.month;
                }
                if (!validDay) {
                    validDay = dateComponentsOfView.day <= self.todayDate.day;
                }
                if (validDay) {
                    wordDayOfHitPoint = [[WDWordDiary sharedWordDiary] createWord:@"" inTimeInterval:[[WDWordDiary sharedWordDiary].currentCalendar dateFromComponents:dateComponentsOfView].timeIntervalSince1970];
                    [self.delegate dashBoardViewController:self createdNewWord:wordDayOfHitPoint];
                }
            }
        }
        
        if (wordDayOfHitPoint) {
            [self.delegate dashBoardViewController:self willDismissWithSelectedWord:wordDayOfHitPoint];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate dashBoardViewControllerDidDismiss:self];
            }];
        }
    }
}

- (void)longPresureGestureRecognizerHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    const CGFloat scaleFactor = 4.5;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (nil == self.dayMonthPendingToRemove) {
            CGPoint hitPoint = [gestureRecognizer locationInView:self.daysOfTheMonthContainerView];
            WDDayMonthView *selectedWordDayView = [self findDayMonthViewForHitPoint:hitPoint];
            WDWord *selectedWordDay = [self findWordForDayMonthView:selectedWordDayView];
            if (!selectedWordDayView.hidden && selectedWordDay != nil && selectedWordDay.word.length > 0) {
                self.dayMonthPendingToRemove = selectedWordDayView;
                self.infoButton.enabled = self.leftNavigationButton.enabled = self.rightNavigationButton.enabled = NO;
                self.wordsOfMonthLabel.hidden = YES;
                self.changeYearMonthButton.hidden = YES;
                self.removeStateImage.hidden = NO;
                [UIView animateWithDuration:0.25 animations:^{
                    self.dayMonthPendingToRemove.layer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
                    self.dayMonthPendingToRemove.alpha = 0.3;
                }];
            }
        }        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.dayMonthPendingToRemove) {
            CGPoint hitPoint = [gestureRecognizer locationInView:self.daysOfTheMonthContainerView];
            WDDayMonthView *selectedWordDayView = [self findDayMonthViewForHitPoint:hitPoint];
            [UIView animateWithDuration:0.25 animations:^{
                self.dayMonthPendingToRemove.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
                self.dayMonthPendingToRemove.alpha = 1.0;
            } completion:^(BOOL finished) {
                if (selectedWordDayView != self.dayMonthPendingToRemove) {
                    [self exitRemoveDayMode];
                } else {
                    WDWord *selectedWordDay = [self findWordForDayMonthView:self.dayMonthPendingToRemove];
                    UILabel *wordSelectedLabel = [[UILabel alloc] initWithFrame:self.wordSlateContainerView.bounds];
                    wordSelectedLabel.backgroundColor = [UIColor clearColor];
                    wordSelectedLabel.attributedText = [[NSAttributedString alloc] initWithString:selectedWordDay.word
                                                                                       attributes:@{
                                                                              NSFontAttributeName:[UIFont fontWithName:selectedWordDay.style.familyFont size:[selectedWordDay.style.familyFont compare:@"Zapfino"] == NSOrderedSame ? 21 : 40 ],
                                                                   NSForegroundColorAttributeName: [UIColor whiteColor]}];
                    wordSelectedLabel.textAlignment = NSTextAlignmentCenter;
                    wordSelectedLabel.adjustsFontSizeToFitWidth = YES;
                    wordSelectedLabel.adjustsLetterSpacingToFitWidth = NO;
                    wordSelectedLabel.minimumScaleFactor = 0.1;
                    wordSelectedLabel.alpha = 0.0;
                    wordSelectedLabel.tag = 100;
                    [self.wordSlateContainerView addSubview:wordSelectedLabel];
                    self.dayMonthPendingToRemove.removeMode = YES;
                    self.infoButton.enabled = NO;
                    self.acceptButton.alpha = self.cancelButton.alpha = 0;
                    [self.acceptButton setTitle:NSLocalizedString(@"TAG_DASHBOARDSCREEN_ACCEPT_ERASE", @"") forState:UIControlStateNormal];
                    [self.cancelButton setTitle:NSLocalizedString(@"TAG_DASHBOARDSCREEN_CANCEL", @"") forState:UIControlStateNormal];
                    self.acceptButton.hidden = self.cancelButton.hidden = NO;
                    [UIView animateWithDuration:0.55 animations:^{
                        self.acceptButton.alpha = self.cancelButton.alpha = 1.0;
                        wordSelectedLabel.alpha = 1.0;
                    }];
                }
            }];
        }
    }
}

#pragma mark - Control Events

- (IBAction)infoButtonPressed:(id)sender
{
    WDInfoScreenViewController *infoScreenViewController = [[WDInfoScreenViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:infoScreenViewController animated:YES completion:nil];
}

- (IBAction)changeMonthYearButtonPressed:(id)sender
{
    self.dateSelectorModeActive = !self.dateSelectorModeActive;
    
    if (self.dateSelectorModeActive) {
        self.backupDateBeforeChangeDateCalendarMode = [[self actualDate] copy];
        [self createMonthsOfTheYearViews];
        [self configureMonthOfTheYearViews];
    } else {
        self.actualDate = self.backupDateBeforeChangeDateCalendarMode;
        self.backupDateBeforeChangeDateCalendarMode = nil;
    }

    self.infoButton.enabled = self.dateSelectorModeActive ? NO : YES;
    [self.changeYearMonthButton setImage:[UIImage imageNamed:self.dateSelectorModeActive ? @"298-circlex.png" : @"83-calendar.png"] forState:UIControlStateNormal];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.6 animations:^{
        for (NSUInteger weekDayIt = 1; weekDayIt < 8; weekDayIt++) {
            [self.daysOfTheWeekTitlesContainerView viewWithTag:weekDayIt].alpha = self.dateSelectorModeActive ? 0.0 : 1.0;
        }
        self.daysOfTheMonthContainerView.alpha = self.dateSelectorModeActive ? 0.0 : 1.0;
        self.monthOfTheYearContainerView.alpha = self.dateSelectorModeActive ? 1.0 : 0.0;
        self.wordSlateContainerView.alpha = self.dateSelectorModeActive ? 0.0 : 1.0;
        
        if (self.dateSelectorModeActive) {
            self.wordsOfMonthLabel.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        if (!self.dateSelectorModeActive) {
            [self configureDayOfTheMonths:NO];
            self.wordsOfMonthLabel.alpha = 0.0;
            [self.monthOfTheYearContainerView removeFromSuperview];
        }
    }];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.6 animations:^{
        self.yearMonthLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self configureMonthAndYearLabel];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:0.5 animations:^{
            self.yearMonthLabel.alpha = 1.0;
        }];
    }];
    

    /*
    self.dateSelectorModeActive = YES;
    
    self.infoButton.enabled = NO;
    
    NSAssert(nil == self.pickerView, @"no deberia de existir otro picker view");
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, (self.daysOfTheMonthContainerView.bounds.size.height - 180.0) / 2.0, self.daysOfTheMonthContainerView.bounds.size.width, 180.0)];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.alpha = 0.0;
    [self.pickerView selectRow:self.todayDate.year - self.actualDate.year inComponent:0 animated:NO];
    [self.pickerView selectRow:self.actualDate.month - 1 inComponent:1 animated:NO];
    CAGradientLayer *pickerViewLayer = [CAGradientLayer layer];
    pickerViewLayer.frame = self.pickerView.bounds;
    pickerViewLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.75].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, [UIColor colorWithWhite:0.0 alpha:0.75].CGColor, nil];
    [self.pickerView.layer addSublayer:pickerViewLayer];
    [self.daysOfTheMonthContainerView addSubview:self.pickerView];
       
    self.changeYearMonthButton.enabled = NO;
    [UIView animateWithDuration:0.55 animations:^{
        for (UIView *viewIt in self.daysOfTheWeekTitlesContainerView.subviews) {
            if ([viewIt isKindOfClass:[UILabel class]]) {
                viewIt.alpha = 0.0;
            }
        }
        for (UIView *viewIt in self.daysOfTheMonthContainerView.subviews) {
            if ([viewIt isKindOfClass:[WDDayMonthView class]]) {
                viewIt.alpha = 0.0;
            }
        }
        self.leftNavigationButton.alpha = self.rightNavigationButton.alpha = 0.0;
        self.wordsOfMonthLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.yearMonthLabel.text = NSLocalizedString(@"TAG_DATESELECTOR_TITLE", "");
        self.cancelButton.hidden = self.acceptButton.hidden = NO;
        [self.acceptButton setTitle:NSLocalizedString(@"TAG_DASHBOARDSCREEN_ACCEPT_GO", @"") forState:UIControlStateNormal];
        [self.cancelButton setTitle:NSLocalizedString(@"TAG_DASHBOARDSCREEN_CANCEL", @"") forState:UIControlStateNormal];
        self.cancelButton.alpha = self.acceptButton.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.yearMonthLabel.alpha = 1.0;
            self.cancelButton.alpha = 1.0;
            self.acceptButton.alpha = 1.0;
            self.pickerView.alpha = 1.0;
        }];
    }];
    */
}

- (IBAction)cancelRemoveDayMode:(id)sender
{
    [self exitRemoveDayMode];
}

- (IBAction)acceptButtonPressed:(id)sender
{
    if (self.dateSelectorModeActive) {
        NSDateComponents *newDateSelected = [[NSDateComponents alloc] init];
        newDateSelected.year = self.todayDate.year - [self.pickerView selectedRowInComponent:0];
        newDateSelected.month = [self.pickerView selectedRowInComponent:1] + 1;
        [self exitChangeYearMonthModeWithSelectedDateComponents:newDateSelected];
    } else if (self.dayMonthPendingToRemove != nil) {
        WDWord *wordOfDayPendingToRemove = [self findWordForDayMonthView:self.dayMonthPendingToRemove];
        [self.delegate dashBoardViewController:self selectRemoveWord:wordOfDayPendingToRemove];
        [self configureDayMonthViewWithoutWordMode:self.dayMonthPendingToRemove];
        [self exitRemoveDayMode];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (self.dateSelectorModeActive) {
        [self exitChangeYearMonthModeWithSelectedDateComponents:nil];
    } else if (self.dayMonthPendingToRemove != nil) {
        [self exitRemoveDayMode];
    }
}

- (void)updateYearMonthData:(NSNumber *)rightDirection
{
    if (![WDUtils is:0.3 equalsTo:self.daysOfTheMonthGridView.gridView.alpha]) {
        self.daysOfTheMonthGridView.gridView.alpha = 0.3;
        [self.daysOfTheMonthGridView setNeedsDisplay];
    }

    [self configureMonthAndYearLabel];
    [self setNumberOfWordsOfTheMonth:YES];

    if (self.pendingMonthNavigationRequest < MAX_PENDING_REQUEST_TO_ATTEND) {
        self.canProcessNavigationUpdate = NO;

        const NSUInteger maxDayMonthViews = DAYS_OF_WEEK * WEEKS_MONTHS;
        for (NSUInteger dayMontViewIt = 0; dayMontViewIt < maxDayMonthViews; dayMontViewIt++) {
            const NSUInteger dayMonthViewIndex = dayMontViewIt + 1;
            WDDayMonthView *dayMonthViewIt = (WDDayMonthView *)[self.daysOfTheMonthContainerView viewWithTag:dayMonthViewIndex];
            if (!dayMonthViewIt.hidden) {
                //CGFloat duration = (float)rand()/(float)RAND_MAX;
                CGFloat duration = 0.7 + (float)rand()/((float)RAND_MAX/0.65);
                if (dayMonthViewIt.layer.sublayers > 0) {
                    dayMonthViewIt.dayOfMonthLabel.textColor = [UIColor lightGrayColor];
                }
                dayMonthViewIt.dayOfMonthLabel.alpha = 1;
                [WDUtils destroyViewGosthEffect:dayMonthViewIt.dayOfMonthLabel withDuration:duration andDisplacement:[rightDirection boolValue] ? -1 * (44 + duration) : (44 + duration)];
                dayMonthViewIt.dayOfMonthLabel.alpha = 0;
            }
        }
        
        [self configureDayOfTheMonths:NO];
    }
    
    self.pendingMonthNavigationRequest--;
}

- (IBAction)leftButtonPressed:(id)sender
{
    if (self.canProcessNavigationUpdate) {
        BOOL updateDate = YES;
        if (self.actualDate.month > 1 && !self.dateSelectorModeActive) {
            self.actualDate.month = self.actualDate.month - 1;
        } else if (self.actualDate.year > 0) {
            self.actualDate.year = self.actualDate.year - 1;
            if (!self.dateSelectorModeActive) {
                self.actualDate.month = 12;
            }
        } else {
            updateDate = NO;
        }
        
        if (updateDate) {
            ++self.pendingMonthNavigationRequest;
            if (self.dateSelectorModeActive) {
                [self configureMonthAndYearLabel];
                [self configureMonthOfTheYearViews];
            } else {
                [self performSelector:@selector(updateYearMonthData:) withObject:[NSNumber numberWithBool:NO] afterDelay:DELAY_UPDATE_DAYMONTHS_NAVIGATION_EFFECT];
            }
        }
    }
}

- (IBAction)rightButtonPressed:(id)sender
{
    if (self.canProcessNavigationUpdate) {
        BOOL updateDate = YES;
        if (self.actualDate.year < self.todayDate.year) {
            if (self.actualDate.month < 12 && !self.dateSelectorModeActive) {
                self.actualDate.month = self.actualDate.month + 1;
            } else {
                self.actualDate.year = self.actualDate.year + 1;
                if (!self.dateSelectorModeActive) {
                    self.actualDate.month = 1;
                }
            }
        } else if (self.actualDate.month < self.todayDate.month && !self.dateSelectorModeActive) {
            self.actualDate.month = self.actualDate.month + 1;
        } else {
            updateDate = NO;
        }
        
        if (updateDate) {
            ++self.pendingMonthNavigationRequest;
            if (self.dateSelectorModeActive) {
                [self configureMonthAndYearLabel];
                [self configureMonthOfTheYearViews];
            } else {
                [self performSelector:@selector(updateYearMonthData:) withObject:[NSNumber numberWithBool:NO] afterDelay:DELAY_UPDATE_DAYMONTHS_NAVIGATION_EFFECT];
            }

        }
    }
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSUInteger numberOfWordsForDate = 0;
    BOOL available = YES;
    NSString *strTitle = nil;
    if (0 == component) {
        const NSUInteger year = self.todayDate.year - row;
        numberOfWordsForDate = [[WDWordDiary sharedWordDiary] findNumberOfWordsInYear:year];
        strTitle = numberOfWordsForDate > 0 ? [NSString stringWithFormat:@"%d (%d)", year,  numberOfWordsForDate] : [NSString stringWithFormat:@"%d", year];

    } else {
        if (self.todayDate.year == self.todayDate.year - [pickerView selectedRowInComponent:0]) {
            available = self.todayDate.month > row;
        }
        numberOfWordsForDate = [[WDWordDiary sharedWordDiary] findNumberOfWordsInMonth:row + 1 ofYear:self.todayDate.year - [pickerView selectedRowInComponent:0]];
        strTitle = numberOfWordsForDate > 0 ? [NSString stringWithFormat:@"%@ (%d)", [WDUtils monthString:row + 1 abreviateMode:NO], numberOfWordsForDate]: [WDUtils monthString:row + 1 abreviateMode:NO];
    }
    
    NSShadow *textShadow = [[NSShadow alloc] init];
    textShadow.shadowOffset = CGSizeMake(0, -2.0);
    textShadow.shadowBlurRadius = 4.0;
    textShadow.shadowColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:strTitle
                                                                     attributes:@{
                                                          NSShadowAttributeName: textShadow,
                                                            NSFontAttributeName: [UIFont fontWithName:component == 0 ?  @"Helvetica" : @"Helvetica" size: component == 0 ? 18.0 : 18.0],
                                                 NSForegroundColorAttributeName: available ? [UIColor blackColor] : [UIColor lightGrayColor],
                                                            }];
    
    return attrString;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat retWidth = 0.0f;
    if (component == 0) {
        retWidth = pickerView.frame.size.width * 0.35;
    } else if (component == 1) {
        retWidth = pickerView.frame.size.width * 0.65;
    }
    
    return retWidth;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger retComponents = 0;
    if (component == 0) {
        retComponents = self.todayDate.year;
    } else if (component == 1) {
        retComponents = 12.0;
    }
    
    return retComponents;
}

#pragma mark - Application Notifications

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (self.dayMonthPendingToRemove) {
        if (self.dayMonthPendingToRemove.alpha != 1.0) {
            self.dayMonthPendingToRemove.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            self.dayMonthPendingToRemove.alpha = 1.0;
        }
        [self cancelButtonPressed:self.cancelButton];
    } else {
        [self cancelButtonPressed:self.cancelButton];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    self.view.alpha = 0.0;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    // ¿ToDo: Comprobar si hemos cambiado de idioma?
    self.canProcessNavigationUpdate = YES;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:1.5 animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
}

#pragma mark - TimeSignificantChangeNotification

- (void)significantTimeChange:(NSNotification *)notification
{
    todayDate_ = nil;
    normalizedRealTodayDate_ = nil;
    
    NSDateComponents *newActualDate = [[WDWordDiary sharedWordDiary].currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit  fromDate:[NSDate date]];
    if ([self logicChangeYearMonthWithSelectedDateComponents:newActualDate]) {
        [self configureDayOfTheMonths:YES];
        [self configureMonthAndYearLabel];
    }
}



@end
