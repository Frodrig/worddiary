//
//  WDAddWordDayViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 22/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDAddWordDayViewController.h"
#import "WDValueSetterModuleViewController.h"
#import "WDUtils.h"
#import "WDWordDiary.h"
#import "WDWord.h"
#import <QuartzCore/QuartzCore.h>

@interface WDAddWordDayViewController ()

@property (weak, nonatomic) IBOutlet UIButton                   *closeButton;
@property (nonatomic, strong) WDValueSetterModuleViewController *yearSetterModuleViewController;
@property (nonatomic, strong) WDValueSetterModuleViewController *monthSetterModuleViewController;
@property (nonatomic, strong) WDValueSetterModuleViewController *daySetterModuleViewController;
@property (weak, nonatomic) IBOutlet UIView                     *yearDateModuleViewContainer;
@property (weak, nonatomic) IBOutlet UIView                     *monthDateModuleViewContainer;
@property (weak, nonatomic) IBOutlet UIView                     *dayDateModuleViewContainer;
@property (weak, nonatomic) IBOutlet UIButton                   *addButton;
@property (nonatomic, strong) NSDateComponents                  *actualDateComponents;
@property (nonatomic, strong) NSNumber                          *maxYears;
@property (nonatomic, strong) NSArray                           *months;
@property (nonatomic, strong) NSNumber                          *maxDays;
@property (nonatomic)NSString                                   *actualValueOfYearModule;
@property (nonatomic)NSString                                   *actualValueOfMonthModule;
@property (nonatomic)NSString                                   *actualValueOfDayModule;
@property (weak, nonatomic) IBOutlet UILabel                    *addButtonLabelAuxiliarInfo;
@property (weak, nonatomic) IBOutlet UIButton                   *goButtonForCreatedWord;

- (NSUInteger)                         indexOfActualValueOfMonthModule;

- (void)                               recalculeMaxMonthsOfYear;
- (void)                               recalculeMaxDaysOfYearAndMonth;
- (void)                               checkAddButtonEnableState;

- (NSNumber *)                         findMaxMonthAvailableForActualYear;

- (BOOL)                               isConfiguredDateValid;

- (NSDateComponents *)                 dateCoponentsOfConfiguredDate;

@end

@implementation WDAddWordDayViewController

@synthesize closeButton                      = closeButton_;
@synthesize yearSetterModuleViewController   = yearSetterModuleViewController_;
@synthesize monthSetterModuleViewController  = monthDateModuleViewController_;
@synthesize daySetterModuleViewController    = daySetterModuleViewController_;
@synthesize yearDateModuleViewContainer      = yearDateModuleViewContainer_;
@synthesize monthDateModuleViewContainer     = monthDateModuleViewContainer_;
@synthesize dayDateModuleViewContainer       = dayDateModuleViewContainer_;
@synthesize actualDateComponents             = actualDateComponents_;
@synthesize maxYears                         = maxYears_;
@synthesize months                           = months_;
@synthesize maxDays                          = maxDays_;
@synthesize actualValueOfYearModule          = actualValueOfYearModule_;
@synthesize actualValueOfMonthModule         = actualValueOfMonthModule_;
@synthesize actualValueOfDayModule           = actualValueOfDayModule_;
@synthesize addButton                        = addButton_;
@synthesize addButtonLabelAuxiliarInfo       = addButtonLabelAuxiliarInfo_;
@synthesize goButtonForCreatedWord           = goButtonForCreatedWord_;

#pragma mark - Properties

- (NSDateComponents *)actualDateComponents
{
    if (actualDateComponents_ == nil) {
        NSDate *actualDate = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        actualDateComponents_ = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:actualDate];
    }
    
    return actualDateComponents_;
}

- (NSNumber *)maxYears
{
    if (maxYears_ == nil) {
        maxYears_ = [NSNumber numberWithUnsignedInteger:self.actualDateComponents.year];
    }
    
    return maxYears_;
}

- (NSArray *)months
{
    if (months_ == nil) {
        months_ = [NSArray arrayWithObjects:NSLocalizedString(@"TAG_MONTH_JANUARY", @""),
                                            NSLocalizedString(@"TAG_MONTH_FEBRUARY", @""),
                                            NSLocalizedString(@"TAG_MONTH_MARCH", @""),
                                            NSLocalizedString(@"TAG_MONTH_APRIL", @""),
                                            NSLocalizedString(@"TAG_MONTH_MAY", @""),
                                            NSLocalizedString(@"TAG_MONTH_JUNE", @""),
                                            NSLocalizedString(@"TAG_MONTH_JULY", @""),
                                            NSLocalizedString(@"TAG_MONTH_AUGUST", @""),
                                            NSLocalizedString(@"TAG_MONTH_SEPTEMBER", @""),
                                            NSLocalizedString(@"TAG_MONTH_OCTOBER", @""),
                                            NSLocalizedString(@"TAG_MONTH_NOVEMBER", @""),
                                            NSLocalizedString(@"TAG_MONTH_DECEMBER", @""),
                   nil];
    }
    
    return months_;
}

- (NSNumber*)maxDays
{
    if (nil == maxDays_) {
        NSUInteger maxDays = 31;
        if ([self.actualValueOfYearModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_YEAR_LABEL", "")] != NSOrderedSame &&
            [self.actualValueOfMonthModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_MONTH_LABEL", @"")] != NSOrderedSame) {
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            dateComponents.year = self.actualValueOfYearModule.integerValue;
            dateComponents.month = [self indexOfActualValueOfMonthModule] + 1;
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[calendar dateFromComponents:dateComponents]];
            maxDays = days.length;
        }
        
        maxDays_ = [NSNumber numberWithInteger:maxDays];
    }
    
    return maxDays_;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        actualValueOfYearModule_ = NSLocalizedString(@"TAG_ADDWORDDAY_YEAR_LABEL", @"");
        actualValueOfMonthModule_ = NSLocalizedString(@"TAG_ADDWORDDAY_MONTH_LABEL", @"");
        actualValueOfDayModule_ = NSLocalizedString(@"TAG_ADDWORDDAY_DAY_LABEL", @"");

        yearSetterModuleViewController_ = [[WDValueSetterModuleViewController alloc] initWithNibName:nil bundle:nil];
        yearSetterModuleViewController_.delegate = self;
        yearSetterModuleViewController_.dataSource = self;
        
        monthDateModuleViewController_ = [[WDValueSetterModuleViewController alloc] initWithNibName:nil bundle:nil];
        monthDateModuleViewController_.delegate = self;
        monthDateModuleViewController_.dataSource = self;
        
        daySetterModuleViewController_ = [[WDValueSetterModuleViewController alloc] initWithNibName:nil bundle:nil];
        daySetterModuleViewController_.delegate = self;
        daySetterModuleViewController_.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self.yearDateModuleViewContainer addSubview:self.yearSetterModuleViewController.view];
    [self.monthDateModuleViewContainer addSubview:self.monthSetterModuleViewController.view];
    [self.dayDateModuleViewContainer addSubview:self.daySetterModuleViewController.view];
    
    self.monthSetterModuleViewController.enabled = NO;
    self.daySetterModuleViewController.enabled = NO;
    
    self.addButtonLabelAuxiliarInfo.text = NSLocalizedString(@"TAG_ADDWORDDAY_INFO_WORDDAYALREADYEXIST", @"");
    self.addButtonLabelAuxiliarInfo.alpha = 0.0;
    [self.goButtonForCreatedWord setTitle:NSLocalizedString(@"TAG_ADDWORDDAY_GO", @"") forState:UIControlStateNormal];
    self.goButtonForCreatedWord.alpha = 0.0;
    self.addButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Control Events

- (IBAction)exitButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)addButtonPressed:(id)sender
{
}

#pragma mark - WDValueSetterModuleViewControllerDataSource

- (NSString *)initialDataValueTextForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController
{
    NSString *retValue = nil;
    if (self.yearSetterModuleViewController == valueSetterModuleViewController) {
        retValue = self.actualValueOfYearModule;
    } else if (self.monthSetterModuleViewController == valueSetterModuleViewController) {
        retValue = self.actualValueOfMonthModule;
    } else if (self.daySetterModuleViewController == valueSetterModuleViewController) {
        return self.actualValueOfDayModule;
    }
    
    return retValue;
}

- (NSString *)actualDataValueTextForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController
{
    NSString *retValue = nil;
    if (valueSetterModuleViewController == self.yearSetterModuleViewController) {
        retValue = self.actualValueOfYearModule;
    } if (valueSetterModuleViewController == self.monthSetterModuleViewController) {
        retValue = self.actualValueOfMonthModule;
    }
    else if (valueSetterModuleViewController == self.daySetterModuleViewController) {
        retValue = self.actualValueOfDayModule;
    }
    
    return retValue;
}

- (NSString *)valueAfterPlusButtonPressedForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController
{
    NSString *retValue = nil;
    BOOL recalculeMaxMonthsOfYear = NO;
    BOOL recalculeMaxDaysOfYearAndMonth = NO;
    if (self.yearSetterModuleViewController == valueSetterModuleViewController) {
        NSUInteger actualYearNumericValue = [self.actualValueOfYearModule integerValue];
        if ([self.actualValueOfYearModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_YEAR_LABEL", @"")] == NSOrderedSame) {
            actualYearNumericValue = self.maxYears.unsignedIntegerValue;
        } else if (actualYearNumericValue < self.maxYears.unsignedIntegerValue) {
            actualYearNumericValue++;
        }
        self.actualValueOfYearModule = [NSString stringWithFormat:@"%d", actualYearNumericValue];
        retValue = self.actualValueOfYearModule;
        recalculeMaxDaysOfYearAndMonth = YES;
        recalculeMaxMonthsOfYear = YES;
        self.monthSetterModuleViewController.enabled = YES;
    } else if (self.monthSetterModuleViewController == valueSetterModuleViewController) {
        NSUInteger actualMonthIndex = [self indexOfActualValueOfMonthModule];
        NSNumber *actualMaxMonthIndex = [self findMaxMonthAvailableForActualYear];
        if ([self.actualValueOfMonthModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_MONTH_LABEL", @"")] != NSOrderedSame && actualMonthIndex < actualMaxMonthIndex.integerValue - 1) {
                actualMonthIndex++;
        }
        self.actualValueOfMonthModule = [self.months objectAtIndex:actualMonthIndex];
        retValue = self.actualValueOfMonthModule;
        recalculeMaxDaysOfYearAndMonth = YES;
        self.daySetterModuleViewController.enabled = YES;
    } else if (self.daySetterModuleViewController == valueSetterModuleViewController) {
        NSUInteger actualDay = self.maxDays.integerValue / 2.0;
        if ([self.actualValueOfDayModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_DAY_LABEL", @"")] != NSOrderedSame) {
            NSUInteger actualNumericDay = [self.actualValueOfDayModule integerValue];
            if (actualNumericDay < self.maxDays.integerValue) {
                actualNumericDay++;
            }
            actualDay = actualNumericDay;
        }
        self.actualValueOfDayModule = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithUnsignedInteger:actualDay]];
        retValue = self.actualValueOfDayModule;
    }
    
    if (recalculeMaxMonthsOfYear) {
        [self recalculeMaxMonthsOfYear];
    }
    
    if (recalculeMaxDaysOfYearAndMonth) {
        [self recalculeMaxDaysOfYearAndMonth];
    }
    
    [self checkAddButtonEnableState];

    return retValue;
}

- (NSString *)valueAfterMinusButtonPressedForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController
{
    NSString *retValue = nil;
    BOOL recalculeMaxDaysOfYearAndMonth = NO;
    if (self.yearSetterModuleViewController == valueSetterModuleViewController) {
        NSUInteger actualYearNumericValue = [self.actualValueOfYearModule integerValue];
        if ([self.actualValueOfYearModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_YEAR_LABEL", @"")] == NSOrderedSame) {
            actualYearNumericValue = self.maxYears.unsignedIntegerValue;
        } else if (actualYearNumericValue > 0) {
            actualYearNumericValue--;
        }
        self.actualValueOfYearModule = [NSString stringWithFormat:@"%d", actualYearNumericValue];
        retValue = self.actualValueOfYearModule;
        recalculeMaxDaysOfYearAndMonth = YES;
        self.monthSetterModuleViewController.enabled = YES;
    } else if (self.monthSetterModuleViewController == valueSetterModuleViewController) {
        NSUInteger actualMonthIndex = [self indexOfActualValueOfMonthModule];
        if ([self.actualValueOfMonthModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_MONTH_LABEL", @"")] != NSOrderedSame && actualMonthIndex > 0) {
            actualMonthIndex--;
        }
        self.actualValueOfMonthModule = [self.months objectAtIndex:actualMonthIndex];
        retValue = self.actualValueOfMonthModule;
        recalculeMaxDaysOfYearAndMonth = YES;
        self.daySetterModuleViewController.enabled = YES;
    } else if (self.daySetterModuleViewController == valueSetterModuleViewController) {
        NSUInteger actualDay = self.maxDays.integerValue / 2.0;
        if ([self.actualValueOfDayModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_DAY_LABEL", @"")] != NSOrderedSame) {
            NSUInteger actualNumericDay = [self.actualValueOfDayModule integerValue];
            if (actualNumericDay > 1) {
                actualNumericDay--;
            }
            actualDay = actualNumericDay;
        }
        self.actualValueOfDayModule = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithUnsignedInteger:actualDay]];
        retValue = self.actualValueOfDayModule;
    }
    
    if (recalculeMaxDaysOfYearAndMonth) {
        [self recalculeMaxDaysOfYearAndMonth];
    }
    
    [self checkAddButtonEnableState];
    
    return retValue;
}

#pragma mark - WDValueSetterModuleViewControllerDelegate

- (void)dataValueButtonPressedForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController
{
}

#pragma mark - Auxiliary

-(NSUInteger)indexOfActualValueOfMonthModule
{
    NSUInteger retIndex = self.actualDateComponents.month - 1;
    if ([self.actualValueOfMonthModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_MONTH_LABEL", @"")] != NSOrderedSame) {
        retIndex = 0;
        for (NSString *stringIt in self.months) {
            if ([stringIt compare:self.actualValueOfMonthModule] == NSOrderedSame) {
                break;
            } else {
                retIndex++;
            }
        }
    }
    
    return retIndex;
}

- (void)recalculeMaxMonthsOfYear
{
    if ([self.actualValueOfMonthModule compare:NSLocalizedString(@"TAG_ADDWORD_MONT_LABEL", @"")] != NSOrderedSame) {
        NSNumber *maxMonthsOfActualYear = [self findMaxMonthAvailableForActualYear];
        NSUInteger indexOfActualMonthData = [self indexOfActualValueOfMonthModule];
        if (indexOfActualMonthData > maxMonthsOfActualYear.integerValue - 1) {
            self.actualValueOfMonthModule = [self.months objectAtIndex:maxMonthsOfActualYear.integerValue - 1];
            [self.monthSetterModuleViewController refreshDataValue];
        }
    }
}

- (void)recalculeMaxDaysOfYearAndMonth
{
    self.maxDays = nil;
    
    if ([self.actualValueOfDayModule compare:NSLocalizedString(@"TAG_ADDWORD_DAY_LABEL", @"")] != NSOrderedSame) {
        NSInteger actualDayValue = [self.actualValueOfDayModule integerValue];
        if (actualDayValue > self.maxDays.integerValue) {
            self.actualValueOfDayModule = [WDUtils convertNumberToStringWithTwoDigitsMin:self.maxDays];
            [self.daySetterModuleViewController refreshDataValue];
        }
    }
}

- (BOOL)isConfiguredDateValid
{
    BOOL isValid = [self.actualValueOfYearModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_YEAR_LABEL", @"")] != NSOrderedSame;
    if (isValid) {
        isValid = [self.actualValueOfMonthModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_MONTH_LABEL", @"")] != NSOrderedSame;
    }
    if (isValid) {
        isValid = [self.actualValueOfDayModule compare:NSLocalizedString(@"TAG_ADDWORDDAY_DAY_LABEL", @"")] != NSOrderedSame;
    }
    
    return isValid;
}

- (NSDateComponents *)dateCoponentsOfConfiguredDate
{
    NSAssert([self isConfiguredDateValid], @"Fecha configurada invalida");
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = [self.actualValueOfYearModule integerValue];
    dateComponents.month = [self.months indexOfObject:self.actualValueOfMonthModule] + 1;
    dateComponents.day = [self.actualValueOfDayModule integerValue];
    
    return dateComponents;
}

- (void)checkAddButtonEnableState
{
    BOOL configuredDataValid = [self isConfiguredDateValid];
    BOOL addButtonEnabled = configuredDataValid;
    if (addButtonEnabled) {
        NSDateComponents *dateComponents = [self dateCoponentsOfConfiguredDate];
        addButtonEnabled = [[WDWordDiary sharedWordDiary] findWordWithDateComponents:dateComponents] == nil;
    }
    
    self.addButton.enabled = addButtonEnabled;
    if (addButtonEnabled) {
        [UIView animateWithDuration:self.addButton.alpha < 1.0 ? 0.35 : 0.0 animations:^{
            self.addButton.alpha = 1.0;
            self.addButtonLabelAuxiliarInfo.alpha = 0.0;
            self.goButtonForCreatedWord.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (self.addButton.layer.animationKeys.count == 0) {
                CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                basicAnimation.fromValue = [NSNumber numberWithFloat:1.0];
                basicAnimation.toValue = [NSNumber numberWithFloat:0.5];
                basicAnimation.removedOnCompletion = NO;
                basicAnimation.duration = 0.4;
                basicAnimation.repeatCount = HUGE_VALF;
                basicAnimation.autoreverses = YES;
                [self.addButton.layer addAnimation:basicAnimation forKey:@"addClaimAnimation"];
            }
        }];
    } else if (configuredDataValid) {
        [self.addButton.layer removeAllAnimations];
        [UIView animateWithDuration:0.35 animations:^{
            self.addButton.alpha = 0.0;
            self.addButtonLabelAuxiliarInfo.alpha = 1.0;
            self.goButtonForCreatedWord.alpha = 1.0;
        }];
    }
}

- (NSNumber *)findMaxMonthAvailableForActualYear
{
    // Nota: Partimos del hecho de que para establecer un mes antes se esta en un año valido
    NSNumber *retNumber = nil;
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    retNumber = [NSNumber numberWithInteger:[self.actualValueOfYearModule integerValue] < currentDateComponents.year ? self.months.count : currentDateComponents.month];
    
    return retNumber;
}

@end
