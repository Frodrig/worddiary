//
//  UIColor+hexColorCreation.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UIColor+hexColorCreation.h"

@implementation UIColor (hexColorCreation)

+ (UIColor *)colorWithHexadecimalValue:(NSString *)hexValue withAlphaComponent:(BOOL)withAlpha skipInitialCharacter:(BOOL)skipInitialCharacter
{
    UIColor *retColor = nil;
    
    NSScanner *scanner = [NSScanner scannerWithString:hexValue];
    if (skipInitialCharacter) {
        scanner.scanLocation = 1;
    }
    
    NSInteger hexResult = 0;
    if ([scanner scanInteger:&hexResult]) {
        CGFloat alphaComponent = 1.0;
        if (withAlpha) {
            alphaComponent = ((hexResult >> 24) & 0xFF) / 255.0;
        }
        CGFloat redComponent = ((hexResult >> 16) & 0xFF) / 255.0;
        CGFloat greenComponent = ((hexResult >> 8) & 0xFF) / 255.0;
        CGFloat blueComponent = (hexResult & 0xFF) / 255.0;
        retColor = [UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
    }
    
    return retColor;
}

@end
