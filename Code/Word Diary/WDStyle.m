//
//  WDFont.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 03/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDStyle.h"
#import "WDWord.h"

@interface WDStyle()

@end

@implementation WDStyle

@dynamic familyFont;
@dynamic word;

@synthesize orderValue = orderValue_;

#pragma mark - Properties

- (NSNumber *)orderValue
{
    if (orderValue_ == nil) {
        NSInteger order = NSNotFound;
        if ([self.familyFont compare:@"SnellRoundhand"] == NSOrderedSame) {
            order = 1;
        } else if ([self.familyFont compare:@"Zapfino"] == NSOrderedSame) {
            order = 2;
        } else if ([self.familyFont compare:@"Baskerville"] == NSOrderedSame) {
            order = 3;
        } else if ([self.familyFont compare:@"PartyLetPlain"] == NSOrderedSame) {
            order = 4;
        }
        
        orderValue_ = [NSNumber numberWithInteger:order];
    }

    return orderValue_;
}

#pragma mark - Compare

- (NSComparisonResult)compare:(WDStyle *)otherFont
{
    return [self.orderValue compare:otherFont.orderValue];
}

@end
