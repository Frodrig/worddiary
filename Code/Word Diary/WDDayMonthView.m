//
//  WDDayMonthView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDDayMonthView.h"
#import "WDUtils.h"
#import <QuartzCore/QuartzCore.h>

@interface WDDayMonthView()

@property (nonatomic, strong) UIImageView *removeModeImage;

@end

@implementation WDDayMonthView

#pragma mark - Synthesize

@synthesize index                    = index_;
@synthesize dayOfTheActualMonthIndex = dayOfTheActualMonthIndex_;
@synthesize dayOfMonthLabel          = dayOfTheMonthLabel_;
@synthesize initialLetterLabel       = initialLetterLabel_;
@synthesize removeMode               = removeMode_;
@synthesize removeModeImage          = removeModeImage_;

#pragma mark - Properties

- (void)setRemoveMode:(BOOL)removeMode
{
    if (removeMode != removeMode_) {
        if (removeMode) {
            self.removeModeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37-circle-x-bw"]];
            self.removeModeImage.contentMode = UIViewContentModeCenter;
            self.removeModeImage.frame = self.bounds;
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = [NSNumber numberWithFloat:1.0];
            animation.toValue = [NSNumber numberWithFloat:0.5];
            animation.removedOnCompletion = NO;
            animation.duration = 1.0;
            animation.repeatCount = HUGE_VALF;
            animation.autoreverses = YES;
            [self.removeModeImage.layer addAnimation:animation forKey:@"blink"];
            
            [self addSubview:self.removeModeImage];
        } else {
            [self.removeModeImage removeFromSuperview];
            self.removeModeImage = nil;
        }
        
        removeMode_ = removeMode;
    }
}

#pragma mark - Init

- (id)initWithIndex:(NSUInteger)index andFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        index_ = index;
        dayOfTheActualMonthIndex_ = 0;
        
        dayOfTheMonthLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, frame.size.width, frame.size.height * 0.4)];
        dayOfTheMonthLabel_.textAlignment = NSTextAlignmentCenter;
        dayOfTheMonthLabel_.text = [[NSNumber numberWithUnsignedInteger:index] stringValue];
        dayOfTheMonthLabel_.textColor = [UIColor whiteColor];
        dayOfTheMonthLabel_.backgroundColor = [UIColor clearColor];
        dayOfTheMonthLabel_.opaque = YES;
        [self addSubview:dayOfTheMonthLabel_];
        
        initialLetterLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, dayOfTheMonthLabel_.frame.size.height, frame.size.width, frame.size.height - dayOfTheMonthLabel_.frame.size.height)];
        initialLetterLabel_.textAlignment = NSTextAlignmentCenter;
        initialLetterLabel_.textColor = [UIColor whiteColor];
        initialLetterLabel_.backgroundColor = [UIColor clearColor];
        initialLetterLabel_.opaque = YES;
        initialLetterLabel_.adjustsFontSizeToFitWidth = YES;
        initialLetterLabel_.minimumScaleFactor = 0.5;
        [self addSubview:initialLetterLabel_];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
