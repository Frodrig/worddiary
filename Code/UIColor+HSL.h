//
//  UIColor+HSL.h
//  PaletteTest
//
//  Created by Fernando Rodríguez Martínez on 07/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HSL)

+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation lightness:(CGFloat)lightness alpha:(CGFloat)alpha;
- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation lightness:(CGFloat *)lightness alpha:(CGFloat *)alpha;
- (UIColor *)offsetWithHue:(CGFloat)h saturation:(CGFloat)s lightness:(CGFloat)l alpha:(CGFloat)alpha;

@end
