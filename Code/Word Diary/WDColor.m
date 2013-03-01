//
//  WDColor.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDColor.h"
#import "WDWord.h"


@implementation WDColor

@dynamic red;
@dynamic green;
@dynamic blue;
@dynamic alpha;
@dynamic wordColor;
@dynamic backgroundColor;

@synthesize colorObject = colorObject_;

#pragma mark - Properties

- (UIColor *)colorObject
{
    if (nil == colorObject_) {
        colorObject_ = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
    }
    
    return colorObject_;
}

#pragma mark - Compare

- (CGFloat)colorComponentsSum
{
    CGFloat sum = self.red + self.green + self.blue + self.alpha;
    return sum;
}

- (NSComparisonResult)compare:(WDColor *)otherColor
{
    CGFloat sum = [self colorComponentsSum];
    CGFloat otherColorSum = [otherColor colorComponentsSum];
    
    return [[NSNumber numberWithFloat:sum] compare:[NSNumber numberWithFloat:otherColorSum]];
}


@end
