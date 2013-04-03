//
//  UIColor+hexColorCreation.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (hexColorCreation)

+ (UIColor *)colorWithHexadecimalValue:(NSString *)hexValue withAlphaComponent:(BOOL)withAlpha skipInitialCharacter:(BOOL)skipInitialCharacter;

@end
