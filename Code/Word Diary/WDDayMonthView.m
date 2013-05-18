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

@end

@implementation WDDayMonthView

#pragma mark - Synthesize

@synthesize index                    = index_;
@synthesize dayOfTheActualMonthIndex = dayOfTheActualMonthIndex_;
@synthesize dayOfMonthLabel          = dayOfTheMonthLabel_;
@synthesize removeMode               = removeMode_;

#pragma mark - Properties

- (void)setRemoveMode:(BOOL)removeMode
{
    if (removeMode != removeMode_) {
        if (removeMode) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
            animation.removedOnCompletion = NO;
            animation.duration = 0.45;
            animation.repeatCount = HUGE_VALF;
            animation.autoreverses = YES;
            [self.layer addAnimation:animation forKey:@"blink"];
            
        } else {
            [self.layer removeAllAnimations];
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
        
        dayOfTheMonthLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, frame.size.width, frame.size.height * 0.45)];
        dayOfTheMonthLabel_.textAlignment = NSTextAlignmentCenter;
        dayOfTheMonthLabel_.text = [[NSNumber numberWithUnsignedInteger:index] stringValue];
        dayOfTheMonthLabel_.textColor = [UIColor whiteColor];
        dayOfTheMonthLabel_.backgroundColor = [UIColor clearColor];
        dayOfTheMonthLabel_.opaque = YES;
        [self addSubview:dayOfTheMonthLabel_];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return nil;
}

@end
