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

@interface WDPalette()

@property(nonatomic, strong) UIColor *lightBackgroundUIColor;
@property(nonatomic, strong) UIColor *wordUIColor;

@end

@implementation WDPalette

@dynamic lightBackground;
@dynamic idName;
@dynamic wordColor;
@dynamic word;

@synthesize lightBackgroundUIColor = lightBackgroundUIColor_;
@synthesize wordUIColor            = wordUIColor_;


#pragma mark - Properties

- (UIColor *)lightBackgroundUIColor
{
    if (nil == lightBackgroundUIColor_) {
        lightBackgroundUIColor_ = [WDUtils convertStringToColor:self.lightBackground];
    }
    
    return lightBackgroundUIColor_;
}

- (UIColor *)wordUIColor
{
    if (nil == wordUIColor_) {
        wordUIColor_ = [UIColor colorWithWhite:[WDUtils brightnessOfColor:[self makeLightBackgroundColorObject]] alpha:1.0];
    }
    
    return wordUIColor_;
}

#pragma mark - makes

- (UIColor *)makeLightBackgroundColorObject
{
    return self.lightBackgroundUIColor;
}

- (UIColor *)makeWordColorObject
{
    return self.wordUIColor;
}

@end
                                            