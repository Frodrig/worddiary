//
//  UIView+RoundedCorners.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 12/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UIView+RoundedCorners.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (RoundedCorners)

-(void)addRoundedCorners:(NSInteger)mask withRadius:(CGFloat)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:mask
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = NO;
}

@end
