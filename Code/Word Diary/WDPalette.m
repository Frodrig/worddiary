//
//  WDPalette.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDPalette.h"
#import "WDWord.h"


@implementation WDPalette

@dynamic accessoriesColor;
@dynamic lightBackground;
@dynamic idName;
@dynamic darkBackground;
@dynamic wordColor;
@dynamic word;

- (UIColor *) makeLightBackgroundColorObject
{
    return [UIColor colorWithCIColor:[CIColor colorWithString:self.lightBackground]];
}

- (UIColor *) makeDarkBackgroundColorObject
{
    return [UIColor colorWithCIColor:[CIColor colorWithString:self.darkBackground]];
}

- (UIColor *) makeWordColorObject
{
    return [UIColor colorWithCIColor:[CIColor colorWithString:self.wordColor]];
}


@end
                                            