//
//  WDDateSelectorView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDateSelectorView.h"

@interface WDDateSelectorView()

@property (nonatomic, strong) UILabel          *titleLabel;
@property (nonatomic, strong) UIButton         *acceptButton;
@property (nonatomic, strong) UIButton         *cancelButton;
@property (nonatomic, strong) UIPickerView     *pickerView;
@property (nonatomic, strong) NSDateComponents *todayYearAndMonthDateComponents;

-(void) actionButtonPressed:(UIButton *)button;

@end

@implementation WDDateSelectorView

#pragma mark - Synthesize

@synthesize todayYearAndMonthDateComponents = todayYearAndMonthDateComponents_;
@synthesize dateComponentsSelected          = dateComponentsSelected_;
@synthesize dataSource                      = dataSource_;
@synthesize delegate                        = delegate_;
@synthesize titleLabel                      = titleLabel_;
@synthesize acceptButton                    = acceptButton_;
@synthesize cancelButton                    = cancelButton_;
@synthesize pickerView                      = pickerView_;

#pragma mark - Properties

- (NSDateComponents *)todayYearAndMonthDateComponents
{
    if (nil == todayYearAndMonthDateComponents_) {
        todayYearAndMonthDateComponents_ = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    }
    
    return todayYearAndMonthDateComponents_;
}

- (NSDateComponents *)dateComponentsSelected
{
    dateComponentsSelected_ = [[NSDateComponents alloc] init];
    dateComponentsSelected_.year = self.todayYearAndMonthDateComponents.year - [self.pickerView selectedRowInComponent:0];
    dateComponentsSelected_.month = [self.pickerView selectedRowInComponent:1] + 1;
    
    return dateComponentsSelected_;
}

- (void)setDataSource:(id<WDDateSelectorViewDataSource>)dataSource
{
    dataSource_ = dataSource;
    [self.pickerView selectRow:self.todayYearAndMonthDateComponents.year - [self.dataSource actualYearSelectedForSelectorView:self] inComponent:0 animated:NO];
    [self.pickerView selectRow:[self.dataSource actualMonthSelectedForSelectorView:self] - 1 inComponent:1 animated:NO];
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 44.0)];
        titleLabel_.text = NSLocalizedString(@"TAG_DATESELECTOR_TITLE", "");
        titleLabel_.font = [UIFont fontWithName:@"Helvetica-Light" size:21.0];
        titleLabel_.textColor = [UIColor whiteColor];
        titleLabel_.backgroundColor = [UIColor clearColor];
        titleLabel_.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel_];
        
        acceptButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [acceptButton_ setImage:[UIImage imageNamed:@"addicon"] forState:UIControlStateNormal];
        acceptButton_.frame = CGRectMake(((frame.size.width / 2.0) / 2.0) - 88.0 / 2.0, titleLabel_.frame.size.height, 88.0, 88.0);
        [acceptButton_ addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:acceptButton_];
        
        cancelButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton_ setImage:[UIImage imageNamed:@"removeicon"] forState:UIControlStateNormal];
        cancelButton_.frame = CGRectMake((frame.size.width / 2.0) + acceptButton_.frame.origin.x, titleLabel_.frame.size.height, 62.0, 62.0);
        [cancelButton_ addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton_];
        
        pickerView_ = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, frame.size.height - 180.0, frame.size.width, 180.0)];
        pickerView_.showsSelectionIndicator = YES;
        pickerView_.delegate = self;
        pickerView_.dataSource = self;
        [self addSubview:pickerView_];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return nil;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strTitle = component == 0 ? [self.dataSource yearTitleForRow:row forSelectorView:self] : [self.dataSource monthTitleForRow:row forSelectorView:self];
    const BOOL available = component == 0 ? YES : [self.dataSource isMonth:row inYear:[self.pickerView selectedRowInComponent:0] availableForSelectionInfSelectorView:self];
    NSShadow *textShadow = [[NSShadow alloc] init];
    textShadow.shadowOffset = CGSizeMake(0, -2.0);
    textShadow.shadowBlurRadius = 4.0;
    textShadow.shadowColor = [UIColor colorWithWhite:0.9 alpha:0.5];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:strTitle
                                                                     attributes:@{
                                                          NSShadowAttributeName: textShadow,
                                                            NSFontAttributeName: [UIFont fontWithName:component == 0 ?  @"Helvetica-Bold" : @"Helvetica" size: component == 0 ? 28.0 : 32.0],
                                                 NSForegroundColorAttributeName: available ? [UIColor blackColor] : [UIColor lightGrayColor],
                                                            NSKernAttributeName: component == 0 ? @2.0f : @2.0f}];
    
    return attrString;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat retWidth = 0.0f;
    if (component == 0) {
        retWidth = self.frame.size.width * 0.3;
    } else if (component == 1) {
        retWidth = self.frame.size.width * 0.7;
    }
    
    return retWidth;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [self.pickerView reloadComponent:1];
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
        retComponents = [self.dataSource numberOfYearsForSelectorView:self];
    } else if (component == 1) {
        retComponents = [self.dataSource numberOfMonthsForSelectorView:self];
    }
    
    return retComponents;
}

#pragma mark - UIControlEvents

-(void) actionButtonPressed:(UIButton *)button
{
    if (button == self.cancelButton) {
        [self.delegate cancelButtonPressedFromDateSelectorView:self];
    } else {
        [self.delegate acceptButtonPressedWithDateComponents:self.dateComponentsSelected fromDateSelectorView:self];
    }
}


@end
