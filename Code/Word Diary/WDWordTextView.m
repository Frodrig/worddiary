//
//  WDWordTextView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordTextView.h"

@implementation WDWordTextView

#pragma mark - Synthesize

@synthesize dataSource = dataSource_;
@synthesize familyFont = familyFont_;

#pragma mark - Properties

// Nota: Esto mejor que se recibiera por inicializacion para evitar confusion.
- (NSString *)familyFont
{
    if (nil == familyFont_) {
        familyFont_ = [self.dataSource actualFamilyFontForWordTextView:self];
    }
    
    return familyFont_;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Draw

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
