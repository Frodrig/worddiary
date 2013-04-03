//
//  WDGradientBackground.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 25/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDGradientBackground : UIView

@property(nonatomic) NSUInteger gradientColorIndex;

+ (NSArray *)gradientColors;
+ (NSArray *)coupleGradientColors;

- (id)initWithFrame:(CGRect)frame andGradientColorIndex:(NSUInteger)index;
- (id)initWithFrame:(CGRect)frame andHexColor:(NSString *)hexColor;

@end
