//
//  WDDateSelectorView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDateSelectorView.h"

@interface WDDateSelectorView()

@property (nonatomic, strong) UILabel      *titleLabel;
@property (nonatomic, strong) UIButton     *acceptButton;
@property (nonatomic, strong) UIButton     *cancelButton;
@property (nonatomic, strong) UIPickerView *pickerView;

@end

@implementation WDDateSelectorView

#pragma mark - Synthesize

@synthesize dataSource    = dataSource_;
@synthesize delegate      = delegate_;
@synthesize titleLabel    = titleLabel_;
@synthesize acceptButton  = acceptButton_;
@synthesize cancelButton  = cancelButton_;
@synthesize pickerView    = pickerView_;

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
        titleLabel_.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel_];
        
        acceptButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [acceptButton_ setImage:[UIImage imageNamed:@"addicon"] forState:UIControlStateNormal];
        acceptButton_.frame = CGRectMake(((frame.size.width / 2.0) / 2.0) - 88.0 / 2.0, titleLabel_.frame.size.height, 88.0, 88.0);
        [self addSubview:acceptButton_];
        
        cancelButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton_ setImage:[UIImage imageNamed:@"removeicon"] forState:UIControlStateNormal];
        cancelButton_.frame = CGRectMake((frame.size.width / 2.0) + acceptButton_.frame.origin.x, titleLabel_.frame.size.height, 88.0, 88.0);
        [self addSubview:cancelButton_];
        
        pickerView_ = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, titleLabel_.frame.size.height + acceptButton_.frame.size.height, frame.size.width, 216.0)];
       
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

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 0;
}

@end
