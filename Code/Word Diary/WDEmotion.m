//
//  WDEmotion.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDEmotion.h"
#import "WDPalette.h"
#import "WDWord.h"


@implementation WDEmotion

@dynamic name;
@dynamic palette;
@dynamic word;

#pragma mark - Actions

- (WDPalette *)findPaletteOfIdName:(NSString *)idName
{
    WDPalette *retPalette = nil;
    for (WDPalette *palette in self.palette) {
        if ([palette.idName compare:idName] == NSOrderedSame) {
            retPalette = palette;
            break;
        }
    }
    
    return retPalette;
}

@end
