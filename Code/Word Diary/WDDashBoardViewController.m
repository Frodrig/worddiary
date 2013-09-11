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
//@property (nonatomic, strong) CAGradientLayer                           *gradientLayer;
@property (weak, nonatomic) IBOutlet WDDaysOfTheMonthContainerView      *daysOfTheMonthGridView;
@property (weak, nonatomic) IBOutlet UIButton                           *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton                           *cancelButton;
@property (weak, nonatomic) IBOutlet UIView                             *wordSlateContainerView;
@property (weak, nonatomic) IBOutlet UIButton                           *leftNavigationButton;
@property (weak, nonatomic) IBOutlet UIButton                           *rightNavigationButton;
@property (weak, nonatomic) IBOutlet UIImageView                        *removeStateImage;
@property (nonatomic, strong) NSTimer                                   *minimumTimeNavigationPressTimer;
@property (weak, nonatomic) IBOutlet WDChangeDateButtonContainerView    *bottomContainerView;
@property (nonatomic) BOOL                                              canProcessNavigationUpdate;
@property (nonatomic, strong) UIView                                    *calendarModeViewContainer;
@property (nonatomic) NSNumber                                          *originalHeightOfDaysOfTheMonthContainerView;
@property (nonatomic) NSDateComponents                                  *backupDateBeforeChangeDateCalendarMode;
@property (nonatomic, strong) WDMonthsOfTheYearContainerView            *monthOfTheYearContainerView;
@property (weak, nonatomic) IBOutlet UILabel                            *wordCounterInYearCalendar;

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

- (void)                updateYearMonthData:(BOOL)rightDirection;

- (void)                launchAddGradientToWordDaysTimer;
- (void)                minimumTimeNavigationPressTimerHandle:(NSTimer *)timer;

- (void)                setNumberOfWordsOfTheMonth:(BOOL)inmediate;
- (NSUInteger)          findNumberOfWordsOfActualMonth;

- (void)                showMonthsOfTheYearCalendarMode:(BOOL)show;

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
//@synthesize gradientLayer                               = gradientLayer_;
@synthesize daysOfTheMonthGridView                      = daysOfTheMonthGridView_;
@synthesize acceptButton                                = acceptButton_;
@synthesize cancelButton                                = cancelButton_;
@synthesize infoButton                                  = infoButton_;
@synthesize wordSlateContainerView                      = wordSlateContainerView_;
@synthesize leftNavigationButton                        = leftNavigationButton_;
@synthesize rightNavigationButton                       = rightNavigationButton_;
@synthesize removeStateImage                            = removeStateImage_;
@synthesize minimumTimeNavigationPressTimer             = minimumTimeNavigationPressTimer_;
@synthesize bottomContainerView                         = bottomContainerView_;
@synthesize canProcessNavigationUpdate                  = canProcessNavigationUpdate_;
@synthesize calendarModeViewContainer                   = calendarModeViewContainer_;
@synthesize originalHeightOfDaysOfTheMonthContainerView = originalHeightOfDaysOfTheMonthContainerView_;
@synthesize backupDateBeforeChangeDateCalendarMode      = backupDateBeforeChangeDateCalendarMode_;
@synthesize monthOfTheYearContainerView                 = monthOfTheYearContainerView_;
@synthesize wordCounterInYearCalendar                   = wordCounterInYearCalendar_;


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
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.minimumTimeNavigationPressTimer invalidate];
    self.minimumTimeNavigationPressTimer = nil;
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
    const NSUInteger numberOfWords = [[WDWordDiary sharedWordDiary] findNumberOfWordsInMonth:self.actualDate.month ofYear:self.actualDate.year filterEmptyWords:YES];
    return  numberOfWords;
    
    /*
     NSArray *wordsOfMonth = [[WDWordDiary sharedWordDiary] findWordsInfMonth:self.actualDate.month ofYear:self.actualDate.year];

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
     */
}

- (void)setNumberOfWordsOfTheMonth:(BOOL)inmediate
{
    const NSUInteger numberOfWords = [self findNumberOfWordsOfActualMonth];
    self.wordsOfMonthLabel.attributedText = [[NSAttributedString alloc]
                                             initWithString:[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"TAG_DASHBOARDSCREEN_WORDCOUNTNAME_PLURAL", @""), [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithInteger:numberOfWords]]]
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
   const BOOL wordsRemoved = [[WDWordDiary sharedWordDiary] removeAllDaysWithoutWord];
    if (wordsRemoved) {
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
        const NSUInteger numWords = [[WDWordDiary sharedWordDiary] findNumberOfWordsInYear:self.actualDate.year filterEmptyWords:YES];
        self.wordCounterInYearCalendar.text = [NSString stringWithFormat:@"%@ %@", [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithUnsignedInteger:numWords]], NSLocalizedString(@"TAG_DASHBOARDSCREEN_WORDCOUNTNAME_PLURAL", @"")];
        self.wordCounterInYearCalendar.textColor = numWords > 0 ? [UIColor whiteColor] : [UIColor darkGrayColor];
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
    NSArray *sublayers = [dayMonthView.layer.sublayers copy];
    for (CALayer *layerIt in sublayers) {
        if ([layerIt isKindOfClass:[CAGradientLayer class]]) {
            CAGradientLayer *gradientLayer = (CAGradientLayer *)layerIt;
            [gradientLayer removeAllAnimations];
            [gradientLayer removeFromSuperlayer];
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
        self.wordsOfMonthLabel.hidden = NO;
        self.wordsOfMonthLabel.alpha = 0;
        [self setNumberOfWordsOfTheMonth:NO];
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
    
    // Para hacer efectivo el cambio, volvemos a asignar el valor original y procedemos a realizar la actualizacion
    self.actualDate = [self.backupDateBeforeChangeDateCalendarMode copy];
    [self logicChangeYearMonthWithSelectedDateComponents:dateComponents];
    [self showMonthsOfTheYearCalendarMode:NO];
}

- (void)createMonthsOfTheYearViews
{
    if (nil == self.monthOfTheYearContainerView) {
        self.monthOfTheYearContainerView = [[WDMonthsOfTheYearContainerView alloc]
                                            initWithFrame:CGRectMake(self.daysOfTheMonthContainerView.frame.origin.x,
                                                                     self.daysOfTheMonthContainerView.frame.origin.y,
                                                                    self.daysOfTheMonthContainerView.frame.size.width,
                                                                    self.daysOfTheMonthContainerView.frame.size.height + (self.bottomContainerView.frame.origin.y - (self.daysOfTheMonthContainerView.frame.origin.y + self.daysOfTheMonthContainerView.frame.size.height)))];
        self.monthOfTheYearContainerView.delegate = self;
    }
    
    [self.datePannelViewContainer addSubview:self.monthOfTheYearContainerView];
    self.monthOfTheYearContainerView.alpha = 0.0;
}

- (void)configureMonthOfTheYearViews
{
    NSUInteger indexMonth = 1;
    for (UIView *monthYearViewIt in self.monthOfTheYearContainerView.subviews) {
        if ([monthYearViewIt isKindOfClass:[WDMonthYearView class]]) {
            WDMonthYearView *monthYearView = (WDMonthYearView *)monthYearViewIt;
            const BOOL beforeDrawContentDot = monthYearView.drawContentDot;
            monthYearView.accesible = self.actualDate.year < self.todayDate.year ? YES : indexMonth <= self.todayDate.month;
            monthYearView.drawContentDot = [[WDWordDiary sharedWordDiary] findNumberOfWordsInMonth:indexMonth ofYear:self.actualDate.year filterEmptyWords:YES];
            if (beforeDrawContentDot != monthYearView.drawContentDot) {
                [monthYearView setNeedsDisplay];
            }
            
            indexMonth++;
        }
    }
}

- (void)showMonthsOfTheYearCalendarMode:(BOOL)show
{
    self.canProcessNavigationUpdate = NO;
    
    if (!show) {
        // Nota: Como queremos que el numero de palabras tenga un fade siempre una vez que se muestra el calendario normal,
        // volveremos a ocultar el valor y haremos que aparezca de nuevo
        [self configureDayOfTheMonths:YES];
        self.wordsOfMonthLabel.alpha = 0;
    }
    self.infoButton.enabled = show ? NO : YES;
    [self.changeYearMonthButton setImage:[UIImage imageNamed:show ? @"746-plus-circle-rotate.png" : @"851-calendar.png"] forState:UIControlStateNormal];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.6 animations:^{
        if (show) {
            for (NSUInteger weekDayIt = 1; weekDayIt < 8; weekDayIt++) {
                [self.daysOfTheWeekTitlesContainerView viewWithTag:weekDayIt].alpha = 0.0;
            }
        }
        self.daysOfTheMonthContainerView.alpha = show ? 0.0 : 1.0;
        self.monthOfTheYearContainerView.alpha = show ? 1.0 : 0.0;
        self.wordSlateContainerView.alpha = show ? 0.0 : 1.0;
    } completion:^(BOOL finished) {
        if (!show) {
            [self setNumberOfWordsOfTheMonth:NO];
            [self.monthOfTheYearContainerView removeFromSuperview];
        }
    }];
    if (show) {
        self.wordCounterInYearCalendar.hidden = NO;
        self.wordCounterInYearCalendar.alpha = 0.0;
    }
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.6 animations:^{
        self.yearMonthLabel.alpha = 0.0;
        if (!show) {
            self.wordCounterInYearCalendar.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        [self configureMonthAndYearLabel];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:0.5 animations:^{
            self.yearMonthLabel.alpha = 1.0;
            if (show) {
                self.wordCounterInYearCalendar.alpha = 1.0;
            } else {
                self.wordCounterInYearCalendar.hidden = YES;
                for (NSUInteger weekDayIt = 1; weekDayIt < 8; weekDayIt++) {
                    [self.daysOfTheWeekTitlesContainerView viewWithTag:weekDayIt].alpha = 1.0;
                }
            }
        } completion:^(BOOL finished) {
            self.canProcessNavigationUpdate = YES;
        }];
    }];

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
        // cancel
        self.actualDate = [self.backupDateBeforeChangeDateCalendarMode copy];
        self.backupDateBeforeChangeDateCalendarMode = nil;
    }
    
    [self showMonthsOfTheYearCalendarMode:self.dateSelectorModeActive];
}

- (IBAction)cancelRemoveDayMode:(id)sender
{
    [self exitRemoveDayMode];
}

- (IBAction)acceptButtonPressed:(id)sender
{
    if (self.dayMonthPendingToRemove) {
        WDWord *wordOfDayPendingToRemove = [self findWordForDayMonthView:self.dayMonthPendingToRemove];
        NSAssert(wordOfDayPendingToRemove, @"");
        [self.delegate dashBoardViewController:self selectRemoveWord:wordOfDayPendingToRemove];
        [self configureDayMonthViewWithoutWordMode:self.dayMonthPendingToRemove];
        [self exitRemoveDayMode];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (self.dateSelectorModeActive) {
        [self exitChangeYearMonthModeWithSelectedDateComponents:nil];
    } else if (self.dayMonthPendingToRemove) {
        [self exitRemoveDayMode];
    }
}

- (void)updateYearMonthData:(BOOL)rightDirection
{
    if (![WDUtils is:0.3 equalsTo:self.daysOfTheMonthGridView.gridView.alpha]) {
        self.daysOfTheMonthGridView.gridView.alpha = 0.3;
        [self.daysOfTheMonthGridView setNeedsDisplay];
    }

    [self configureMonthAndYearLabel];
    [self setNumberOfWordsOfTheMonth:YES];
    
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
            [WDUtils destroyViewGosthEffect:dayMonthViewIt.dayOfMonthLabel withDuration:duration andDisplacement:rightDirection ? -1 * (44 + duration) : (44 + duration)];
            dayMonthViewIt.dayOfMonthLabel.alpha = 0;
        }
    }
    
    [self configureDayOfTheMonths:NO];

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
            if (self.dateSelectorModeActive) {
                [self configureMonthAndYearLabel];
                [self configureMonthOfTheYearViews];
            } else {
                [self updateYearMonthData:NO];
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
            if (self.dateSelectorModeActive) {
                [self configureMonthAndYearLabel];
                [self configureMonthOfTheYearViews];
            } else {
                [self updateYearMonthData:YES];
            }
        }
    }
}

#pragma mark - WDMonthOfTheYearContainerViewDelegate

- (void) monthOfTheYearContainerViewIndexMonthSelected:(NSUInteger)indexMonth
{
    NSAssert(self.dateSelectorModeActive, @"deberiamos de estar en este modo");
    
    NSDateComponents *newDateSelected = [[NSDateComponents alloc] init];
    newDateSelected.year = self.actualDate.year;
    newDateSelected.month = indexMonth;
    [self exitChangeYearMonthModeWithSelectedDateComponents:newDateSelected];
}

#pragma mark - Application Notifications

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (self.dayMonthPendingToRemove) {
        if (self.dayMonthPendingToRemove.alpha != 1.0) {
            self.dayMonthPendingToRemove.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            self.dayMonthPendingToRemove.alpha = 1.0;
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    // ¿ToDo: Comprobar si hemos cambiado de idioma?
    if (nil == self.presentedViewController) {
        self.canProcessNavigationUpdate = YES;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:1.5 animations:^{
            self.view.alpha = 1.0;
        }];
    }
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
    
    if (self.dateSelectorModeActive) {
        [self configureMonthOfTheYearViews];

    } else {
        NSDateComponents *newActualDate = [[WDWordDiary sharedWordDiary].currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit  fromDate:[NSDate date]];
        if (newActualDate.year != self.actualDate.year ||
            (newActualDate.year == self.actualDate.year && newActualDate.month != self.actualDate.month) ||
            (newActualDate.year == self.actualDate.year && newActualDate.month == self.actualDate.month && newActualDate.day != self.actualDate.day)) {
            // Se ha retrocedido la fecha (solo podra ocurrir al volver desde el exterior)
            if ([self logicChangeYearMonthWithSelectedDateComponents:newActualDate]) {
                [self configureDayOfTheMonths:YES];
                [self configureMonthAndYearLabel];
            }
        } else {
            // Solo actualizamos los dias del mes en el que estamos o estabamos. NO cambiamos automaticamente de mes
            [self configureDayOfTheMonths:YES];
        }
    }
}



@end
