//
//  WDTopInfoNavigationWordMenuView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 11/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDTopInfoNavigationWordMenuView.h"

@implementation WDTopInfoNavigationWordMenuView

#pragma mark - Synthesize

@synthesize backNavigationButton = backNavigationButton_;
@synthesize infoNavigationLabel  = infoNavigationLabel_;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
