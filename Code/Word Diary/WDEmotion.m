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

#pragma mark - Synthesize

@synthesize priorityOrder = priorityOrder_;

- (NSUInteger)priorityOrder
{
    // 1..7
    if (priorityOrder_ == 0) {
        if ([self.name compare:@"TAG_EMOTION_NAME_NEUTRAL"] == NSOrderedSame) {
            priorityOrder_ = 1;
        } else if ([self.name compare:@"TAG_EMOTION_NAME_JOY"] == NSOrderedSame) {
            priorityOrder_ = 2;
        } else if ([self.name compare:@"TAG_EMOTION_NAME_LOVE"] == NSOrderedSame) {
            priorityOrder_ = 3;
        } else if ([self.name compare:@"TAG_EMOTION_NAME_SURPRISE"] == NSOrderedSame) {
            priorityOrder_ = 4;
        } else if ([self.name compare:@"TAG_EMOTION_NAME_SADNESS"] == NSOrderedSame) {
            priorityOrder_ = 5;
        } else if ([self.name compare:@"TAG_EMOTION_NAME_FEAR"] == NSOrderedSame) {
            priorityOrder_ = 6;
        } else if ([self.name compare:@"TAG_EMOTION_NAME_DISGUST"] == NSOrderedSame) {
            priorityOrder_ = 7;
        }
    }
    
    return priorityOrder_;
}

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

#pragma mark - Comparison

- (NSComparisonResult)compare:(WDEmotion *)otherEmotion
{
    NSComparisonResult result =  NSOrderedSame;
    if (otherEmotion.priorityOrder < self.priorityOrder) {
        result = NSOrderedDescending;
    } else if (otherEmotion.priorityOrder > self.priorityOrder) {
        result = NSOrderedAscending;
    }

    return result;
}

#pragma mark - Description

- (NSString *)description
{
    NSString *description = [super description];
    
    description = [description stringByAppendingFormat:@"\nName: %@", self.name];
    description = [description stringByAppendingPathComponent:@"\nPalettes:"];
    for (WDPalette *paletteIt in self.palette) {
        description = [description stringByAppendingFormat:@"\nPalette: %@", paletteIt.idName];
    }
    
    return description;
}

@end
