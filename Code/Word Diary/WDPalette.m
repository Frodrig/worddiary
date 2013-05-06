//
//  WDPalette.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDPalette.h"
#import "WDWord.h"
#import "WDUtils.h"


@implementation WDPalette

@dynamic lightBackground;
@dynamic idName;
@dynamic wordColor;
@dynamic word;

- (UIColor *) makeLightBackgroundColorObject
{
    return [WDUtils convertStringToColor:self.lightBackground];
}

- (UIColor *) makeWordColorObject
{
    return [UIColor colorWithWhite:[WDUtils brightnessOfColor:[self makeLightBackgroundColorObject]] alpha:1.0];
}


@end
                                            