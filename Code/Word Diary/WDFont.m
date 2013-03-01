//
//  WDFont.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDFont.h"
#import "WDWord.h"


@implementation WDFont

@dynamic family;
@dynamic word;

#pragma mark - Compare

- (NSComparisonResult)compare:(WDFont *)otherFont
{
    return [self.family compare:otherFont.family];
}

@end
