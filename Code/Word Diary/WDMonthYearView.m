//
//  WDMonthYearView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDMonthYearView.h"
#import <QuartzCore/QuartzCore.h>

@interface WDMonthYearView()

@property (nonatomic, strong)  UILabel  *monthTitleLabel;
@property (nonatomic, strong)  NSString *monthString;

@end

@implementation WDMonthYearView

@synthesize monthTitleLabel     = monthTitleLabel_;
@synthesize drawContentDot      = drawContentDot_;
@synthesize accesible           = accesible_;
@synthesize monthString         = monthString_;

#pragma mark - Properties

- (void)setDrawContentDot:(BOOL)drawContentDot
{
    if (drawContentDot != drawContentDot_) {
        drawContentDot_ = drawContentDot;
    }
}

- (void)setAccesible:(BOOL)accesible
{
    if (accesible != accesible_) {
        accesible_ = accesible;
        [self updateAttributedText];
    }
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andLabel:@"¿?"];
}

- (id)initWithFrame:(CGRect)frame andLabel:(NSString *)label
{
    self = [super initWithFrame:frame];
    if (self) {
        // MUY IMPORTANTE: Evita que DrawRect dibuje todo negro
        self.opaque = NO;
        
        monthString_ = label;
        drawContentDot_ = NO;
    
        monthTitleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height * 0.85)];
        [self updateAttributedText];
        monthTitleLabel_.textAlignment = NSTextAlignmentCenter;
        monthTitleLabel_.backgroundColor = [UIColor clearColor];
        [self addSubview:monthTitleLabel_];
    }
    
    return self;
}

#pragma mark - Auxiliary

- (void)updateAttributedText
{
    monthTitleLabel_.attributedText = [[NSAttributedString alloc] initWithString:monthString_ attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:21.0], NSForegroundColorAttributeName: accesible_ ? [UIColor lightGrayColor] : [UIColor darkGrayColor], NSBackgroundColorAttributeName: [UIColor clearColor], NSKernAttributeName: [NSNumber numberWithFloat:5.0]}];
}

#pragma mark - Drawrect

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
  - (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    if (self.drawContentDot) {
        CGPoint drawStartPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height * 0.85);    CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(contextRef);
        const CGFloat twoPiRadians = 6.28318531;
        CGContextSetAllowsAntialiasing(contextRef, true);
        CGContextSetLineWidth(contextRef, 1.0);
        CGContextSetFillColorWithColor(contextRef, [UIColor lightGrayColor].CGColor);
        CGContextAddArc(contextRef, drawStartPoint.x, drawStartPoint.y, 5.0, 0.0, twoPiRadians, 0);
        CGContextFillPath(contextRef);
        CGContextRestoreGState(contextRef);
    }
}

- (NSString *)description
{
    return self.monthTitleLabel.text;
}


@end
