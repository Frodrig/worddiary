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
#import <QuartzCore/QuartzCore.h>

const NSUInteger DAYS_OF_WEEK = 7;
const NSUInteger WEEKS_MONTHS = 5;

@interface WDDashBoardViewController ()

@property (weak, nonatomic) IBOutlet UIView                             *datePannelViewContainer;
@property (nonatomic, strong) NSDateComponents                          *actualDate;
@property (nonatomic, strong) NSDateComponents                          *todayDate;
@property (weak, nonatomic) IBOutlet UILabel                            *yearMonthLabel;
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

- (void)                createDayOfTheMonthsViews;

- (void)                removeEmptyWordsDays;

- (void)                configureDaysOfTheWeekTitles;
- (void)                configureMonthAndYearLabel;
- (void)                configureDayOfTheMonths;
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
- (void)                exitChangeYearMonthModeWithSelectedDateComponents:(NSDateComponents *)dateComponents;

- (void)                addGradientLayerToDayMonthView:(WDDayMonthView *)dayMonthView withWord:(WDWord *)word;
- (void)                removeGradientLayerOfDayMonthView:(WDDayMonthView *)dayMonthView;

@end

@implementation WDDashBoardViewController

#pragma mark - Synthesize

@synthesize datePannelViewContainer          = datePannelViewContainer_;
@synthesize actualDate                       = actualDate_;
@synthesize yearMonthLabel                   = yearMonthLabel_;
@synthesize daysOfTheWeekTitlesContainerView = daysOfTheWeekContainerView_;
@synthesize daysOfTheMonthContainerView      = daysOfTheMonthContainerView_;
@synthesize tapGestureRecognizer             = tapGestureRecognizer_;
@synthesize longPresureGestureRecognizer     = longPresureGestureRecognizer_;
@synthesize delegate                         = delegate_;
@synthesize dataSource                       = dataSource_;
@synthesize normalizedRealTodayDate          = normalizedRealTodayDate_;
@synthesize dateSelectorModeActive           = dateSelectorModeActive_;
@synthesize todayDate                        = todayDate_;
@synthesize changeYearMonthButton            = changeYearMonthButton_;
@synthesize gradientLayer                    = gradientLayer_;
@synthesize daysOfTheMonthGridView           = daysOfTheMonthGridView_;
@synthesize acceptButton                     = acceptButton_;
@synthesize cancelButton                     = cancelButton_;
@synthesize pickerView                       = pickerView_;
@synthesize infoButton                       = infoButton_;
@synthesize wordSlateContainerView           = wordSlateContainerView_;
@synthesize leftNavigationButton             = leftNavigationButton_;
@synthesize rightNavigationButton            = rightNavigationButton_;

#pragma mar - Properties

- (NSDateComponents *)todayDate
{
    if (todayDate_ == nil) {
        todayDate_ = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    }
    
    return todayDate_;
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
    
    self.actualDate = [self.dataSource dateComponentsFromWordDaySelectedForDashBoardViewController:self];
    
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
    [self configureDayOfTheMonths];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self removeEmptyWordsDays];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

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
            CGRect monthViewFrame = CGRectMake(dayOfTheWeekIt == 0 ? 0 : 44.0 * dayOfTheWeekIt + 6.0,
                                               rowIt * 44.0,
                                               dayOfTheWeekIt == 0 || dayOfTheWeekIt == DAYS_OF_WEEK - 1 ? 50.0 : 44.0,
                                               44.0);
            WDDayMonthView *monthViewIt = [[WDDayMonthView alloc] initWithIndex:indexMonthView andFrame:monthViewFrame];
            monthViewIt.tag = indexMonthView;
            [self.daysOfTheMonthContainerView insertSubview:monthViewIt belowSubview:self.daysOfTheMonthGridView];

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
            dateComponentOfDay.day = dayMonthViewIt.dayOfTheActualMonthIndex;
            WDWordDiary *wordDiary = [WDWordDiary sharedWordDiary];
            WDWord *wordOfCalendarDay = [wordDiary findWordWithDateComponents:dateComponentOfDay];
            dayMonthViewIt.backgroundColor = [UIColor clearColor];
            dayMonthViewIt.dayOfMonthLabel.textColor = [wordOfCalendarDay.palette makeWordColorObject];
            dayMonthViewIt.dayOfMonthLabel.text = [NSString stringWithFormat:@"%d", dayMonthViewIt.dayOfTheActualMonthIndex];
            if (wordOfCalendarDay && wordOfCalendarDay.word.length > 0) {
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
    dayMonthView.backgroundColor = [UIColor clearColor];
    dayMonthView.layer.cornerRadius = 0.0;
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
        self.infoButton.enabled = self.leftNavigationButton.enabled = self.rightNavigationButton.enabled = self.changeYearMonthButton.enabled = YES;
        [selectedWordLabel removeFromSuperview];
    }];
}

- (void)exitChangeYearMonthModeWithSelectedDateComponents:(NSDateComponents *)dateComponents
{
    NSAssert(self.dateSelectorModeActive, @"Deberia de estar activo el modo de cambio de fecha");
   
    self.dateSelectorModeActive = NO;
    
    if (dateComponents != nil && (self.actualDate.year != dateComponents.year || self.actualDate.month != dateComponents.month)) {
        self.actualDate.year = dateComponents.year;
        self.actualDate.month = dateComponents.month;
        [self configureDayOfTheMonths];
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
        } completion:^(BOOL finished) {
            self.changeYearMonthButton.enabled = YES;
            self.infoButton.enabled = YES;
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
                if (dateComponentsOfView.year <= self.todayDate.year && dateComponentsOfView.month <= self.todayDate.month && dateComponentsOfView.day <= self.todayDate.day) {
                    wordDayOfHitPoint = [[WDWordDiary sharedWordDiary] createWord:@"" inTimeInterval:[[NSCalendar currentCalendar] dateFromComponents:dateComponentsOfView].timeIntervalSince1970];
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
                self.infoButton.enabled = self.leftNavigationButton.enabled = self.rightNavigationButton.enabled = self.changeYearMonthButton.enabled = NO;
                [UIView animateWithDuration:0.25 animations:^{
                    self.dayMonthPendingToRemove.layer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
                    self.dayMonthPendingToRemove.alpha = 0.3;
                }];
            }
        }        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.dayMonthPendingToRemove) {
            [UIView animateWithDuration:0.25 animations:^{
                self.dayMonthPendingToRemove.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
                self.dayMonthPendingToRemove.alpha = 1.0;
            } completion:^(BOOL finished) {
                WDWord *selectedWordDay = [self findWordForDayMonthView:self.dayMonthPendingToRemove];
                UILabel *wordSelectedLabel = [[UILabel alloc] initWithFrame:self.wordSlateContainerView.bounds];
                wordSelectedLabel.backgroundColor = [UIColor clearColor];
                wordSelectedLabel.attributedText = [[NSAttributedString alloc] initWithString:selectedWordDay.word
                                                                                   attributes:@{
                                                                          NSFontAttributeName:[UIFont fontWithName:selectedWordDay.style.familyFont size:[selectedWordDay.style.familyFont compare:@"Zapfino"] == NSOrderedSame ? 34 : 75 ],
                                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                          NSKernAttributeName: @2.0f}];
                wordSelectedLabel.textAlignment = NSTextAlignmentCenter;
                wordSelectedLabel.adjustsFontSizeToFitWidth = YES;
                wordSelectedLabel.minimumScaleFactor = 0.3;
                wordSelectedLabel.alpha = 0.0;
                wordSelectedLabel.tag = 100;
                [self.wordSlateContainerView addSubview:wordSelectedLabel];
                self.dayMonthPendingToRemove.removeMode = YES;
                self.infoButton.enabled = NO;
                self.changeYearMonthButton.enabled = NO;
                self.acceptButton.alpha = self.cancelButton.alpha = 0;
                self.acceptButton.hidden = self.cancelButton.hidden = NO;
                [UIView animateWithDuration:0.55 animations:^{
                    self.acceptButton.alpha = self.cancelButton.alpha = 1.0;
                    wordSelectedLabel.alpha = 1.0;
                }];
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
    NSAssert(!self.dateSelectorModeActive, @"No deberia de estar activo el modo de cambio de fecha");
    
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
    } completion:^(BOOL finished) {
        self.yearMonthLabel.text = NSLocalizedString(@"TAG_DATESELECTOR_TITLE", "");
        self.cancelButton.hidden = self.acceptButton.hidden = NO;
        self.cancelButton.alpha = self.acceptButton.alpha = 0.0;
        [UIView animateWithDuration:0.5 animations:^{
            self.yearMonthLabel.alpha = 1.0;
            self.cancelButton.alpha = 1.0;
            self.acceptButton.alpha = 1.0;
            self.pickerView.alpha = 1.0;
        }];
    }];
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

- (void)updateYearMonthData:(BOOL)rightDirection
{
    const NSUInteger maxDayMonthViews = DAYS_OF_WEEK * WEEKS_MONTHS;
    for (NSUInteger dayMontViewIt = 0; dayMontViewIt < maxDayMonthViews; dayMontViewIt++) {
        const NSUInteger dayMonthViewIndex = dayMontViewIt + 1;
        WDDayMonthView *dayMonthViewIt = (WDDayMonthView *)[self.daysOfTheMonthContainerView viewWithTag:dayMonthViewIndex];
        //CGFloat duration = (float)rand()/(float)RAND_MAX;
        CGFloat duration = (float)rand()/((float)RAND_MAX/1.35);
        if (duration < 0.40) {
            duration = 0.40;
        }
        if (dayMonthViewIt.layer.sublayers > 0) {
            dayMonthViewIt.dayOfMonthLabel.textColor = [UIColor lightGrayColor];
        }
        [WDUtils destroyViewGosthEffect:dayMonthViewIt withDuration:duration andDisplacement:rightDirection ? -1 * (44 + duration) : (44 + duration)];
        dayMonthViewIt.alpha = 0.0;
    }
 
    [self configureMonthAndYearLabel];
    [self configureDayOfTheMonths];
    
    for (NSUInteger dayMontViewIt = 0; dayMontViewIt < maxDayMonthViews; dayMontViewIt++) {
        const NSUInteger dayMonthViewIndex = dayMontViewIt + 1;
        WDDayMonthView *dayMonthViewIt = (WDDayMonthView *)[self.daysOfTheMonthContainerView viewWithTag:dayMonthViewIndex];
        [UIView animateWithDuration:0.25 animations:^{
            dayMonthViewIt.alpha = 1.0;
        }];
    }
}

- (IBAction)leftButtonPressed:(id)sender
{
    BOOL updateDate = YES;
    if (self.actualDate.month > 1) {
        self.actualDate.month = self.actualDate.month - 1;
    } else if (self.actualDate.year > 0) {
        self.actualDate.year = self.actualDate.year - 1;
        self.actualDate.month = 12;
    } else {
        updateDate = NO;
    }
    
    if (updateDate) {
        [self updateYearMonthData:NO];
    }
}

- (IBAction)rightButtonPressed:(id)sender
{
    BOOL updateDate = YES;
    if (self.actualDate.year < self.todayDate.year) {
        if (self.actualDate.month < 12) {
            self.actualDate.month = self.actualDate.month + 1;
        } else {
            self.actualDate.year = self.actualDate.year + 1;
            self.actualDate.month = 1;
        }
    } else if (self.actualDate.month < self.todayDate.month) {
        self.actualDate.month = self.actualDate.month + 1;
    } else {
        updateDate = NO;
    }
    
    if (updateDate) {
        [self updateYearMonthData:YES];
    }
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    BOOL available = YES;
    NSString *strTitle = nil;
    if (0 == component) {
        const NSUInteger year = self.todayDate.year - row;
        strTitle = [NSString stringWithFormat:@"%d", year];
    } else {
        strTitle = [WDUtils monthString:row + 1 abreviateMode:NO];
        if (self.todayDate.year == self.todayDate.year - [pickerView selectedRowInComponent:0]) {
            available = self.todayDate.month > row;
        }
    }
    
    NSShadow *textShadow = [[NSShadow alloc] init];
    textShadow.shadowOffset = CGSizeMake(0, -2.0);
    textShadow.shadowBlurRadius = 4.0;
    textShadow.shadowColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:strTitle
                                                                     attributes:@{
                                                          NSShadowAttributeName: textShadow,
                                                            NSFontAttributeName: [UIFont fontWithName:component == 0 ?  @"Helvetica" : @"Helvetica" size: component == 0 ? 24.0 : 28.0],
                                                 NSForegroundColorAttributeName: available ? [UIColor blackColor] : [UIColor lightGrayColor],
                                                            }];
    
    return attrString;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat retWidth = 0.0f;
    if (component == 0) {
        retWidth = pickerView.frame.size.width * 0.3;
    } else if (component == 1) {
        retWidth = pickerView.frame.size.width * 0.7;
    }
    
    return retWidth;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [pickerView reloadComponent:1];
    }
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

@end
