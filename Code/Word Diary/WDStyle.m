//
//  WDFont.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDStyle.h"
#import "WDWord.h"


@implementation WDStyle

@dynamic familyFont;
@dynamic word;

#pragma mark - Compare

- (NSComparisonResult)compare:(WDStyle *)otherFont
{
    return [self.familyFont compare:otherFont.familyFont];
}

@end
