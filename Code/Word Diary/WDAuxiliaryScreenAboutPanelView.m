//
//  WDAuxiliaryScreenAboutPanelView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDAuxiliaryScreenAboutPanelView.h"

@implementation WDAuxiliaryScreenAboutPanelView

#pragma mark - Synthesize

@synthesize wordDiaryTitleLabel         = wordDiaryTitleLabel_;
@synthesize wordDiaryURLButton          = wordDiaryURLButton_;
@synthesize designedAndDevelopedByLabel = designedAndDevelopedByLabel_;
@synthesize developerNameLabel          = developerNameLabel_;
@synthesize twitterURLButton            = twitterURLButton_;
@synthesize allRightReservedLabel       = allRightReservedLabel_;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
