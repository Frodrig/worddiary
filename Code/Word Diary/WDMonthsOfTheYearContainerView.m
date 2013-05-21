//
//  WDMonthsOfTheYearContainerView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDMonthsOfTheYearContainerView.h"
#import "WDMonthYearView.h"
#import "WDUtils.h"

@interface WDMonthsOfTheYearContainerView()

@property (nonatomic, strong) UITapGestureRecognizer    *tapGestureRecognizer;

- (void)tapGestureRecognizerHandle:(UIGestureRecognizer *)gesture;

@end

@implementation WDMonthsOfTheYearContainerView

@synthesize gridView             = gridView_;
@synthesize delegate             = delegate_;
@synthesize tapGestureRecognizer = tapGestureRecognizer_;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        const NSUInteger maxRows = 4;
        const NSUInteger maxColumns = 3;
        const CGFloat monthYearViewWidth = frame.size.width / maxColumns;
        const CGFloat monthYearViewHeight = frame.size.height / maxRows;
        for (NSUInteger rowIt = 0; rowIt < maxRows; rowIt++) {
            for (NSUInteger columnIt = 0; columnIt < maxColumns; columnIt++) {
                const NSUInteger monthIndex = rowIt * maxColumns + columnIt + 1;
                CGRect monthOfTheYearRect = CGRectMake(columnIt * monthYearViewWidth,
                                                       rowIt * monthYearViewHeight,
                                                       monthYearViewWidth,
                                                       monthYearViewHeight);
                WDMonthYearView *monthOfTheYearView = [[WDMonthYearView alloc]
                                                       initWithFrame:monthOfTheYearRect
                                                       andLabel:[WDUtils monthString:monthIndex abreviateMode:YES]];
                monthOfTheYearView.tag = monthIndex;
                [self addSubview:monthOfTheYearView];
            }
        }
        
        tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
        tapGestureRecognizer_.numberOfTapsRequired = 1;
        tapGestureRecognizer_.numberOfTouchesRequired = 1;

        gridView_ = [[WDMonthOfTheYearContainerGridView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [self addSubview:gridView_];
    }
    return self;
}

#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // Sombras
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(contextRef, CGSizeMake(0.0, 0.5), 15.0, [UIColor colorWithWhite:1.0 alpha:1].CGColor);
    CGContextSetLineWidth(contextRef, 1.0);
    CGContextMoveToPoint(contextRef, 0, 0.0);
    CGContextAddLineToPoint(contextRef, self.frame.origin.x + self.frame.size.width, 0.0);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);
    
    CGContextSaveGState(contextRef);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(contextRef, CGSizeMake(0.0, 0.5), 15.0, [UIColor colorWithWhite:1.0 alpha:1].CGColor);
    CGContextSetLineWidth(contextRef, 1);
    CGContextMoveToPoint(contextRef, 0, self.frame.size.height);
    CGContextAddLineToPoint(contextRef, self.frame.origin.x + self.frame.size.width, self.frame.size.height);
    CGContextStrokePath(contextRef);
    CGContextRestoreGState(contextRef);

}

#pragma mark - Gestures

- (void)tapGestureRecognizerHandle:(UIGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self];
    WDMonthYearView *monthYearSelected = nil;
    for (UIView *viewIt in self.subviews) {
        if ([viewIt isKindOfClass:[WDMonthYearView class]]) {
            if (CGRectContainsPoint(viewIt.frame, location)) {
                monthYearSelected = (WDMonthYearView *)viewIt;
                break;
            }
        }
    }
    
    if (monthYearSelected) {
        [self.delegate monthOfTheYearContainerViewIndexMonthSelected:monthYearSelected.tag];
    }
}

@end
