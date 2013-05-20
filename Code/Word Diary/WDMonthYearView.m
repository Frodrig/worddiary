//
//  WDMonthYearView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDMonthYearView.h"

@interface WDMonthYearView()

@property (nonatomic, strong) UILabel *monthTitleLabel;

@end

@implementation WDMonthYearView

@synthesize monthTitleLabel     = monthTitleLabel_;
@synthesize drawContentDot      = drawContentDot_;
@synthesize accesible           = accesible_;

#pragma mark - Properties

- (void) setDrawContentDot:(BOOL)drawContentDot
{
    if (drawContentDot != drawContentDot_) {
        drawContentDot_ = drawContentDot;
        [self setNeedsDisplay];
    }
}

- (void) setAccesible:(BOOL)accesible
{
    if (accesible != accesible_) {
        accesible_ = accesible;
        self.monthTitleLabel.textColor = accesible ? [UIColor lightGrayColor] : [UIColor darkGrayColor];
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
        drawContentDot_ = NO;
        
        monthTitleLabel_ = [[UILabel alloc] initWithFrame:frame];
        monthTitleLabel_.backgroundColor = [UIColor redColor];
        monthTitleLabel_.textAlignment = NSTextAlignmentCenter;
        monthTitleLabel_.textColor = [UIColor lightGrayColor];
        monthTitleLabel_.text = label;
        [self addSubview:monthTitleLabel_];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    if (self.drawContentDot) {
        CGPoint drawStartPoint = CGPointMake(self.frame.size.width / 2.0, self.frame.origin.y + (self.frame.size.height - self.frame.size.height * 0.25));
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextSaveGState(contextRef);
        const CGFloat twoPiRadians = 6.28318531;
        const CGFloat decoratorRadius = 2.0;
        CGContextSetAllowsAntialiasing(contextRef, true);
        CGContextSetLineWidth(contextRef, 1.0);
        CGContextSetFillColor(contextRef, CGColorGetComponents([UIColor lightGrayColor].CGColor));
        CGContextAddArc(contextRef, drawStartPoint.x, drawStartPoint.y, decoratorRadius, 0.0, twoPiRadians, 0);
        CGContextFillPath(contextRef);
        CGContextRestoreGState(contextRef);
    }
}

- (NSString *)description
{
    return self.monthTitleLabel.text;
}


@end
