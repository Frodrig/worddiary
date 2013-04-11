//
//  WDIndexDiaryCollectionViewCell.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 10/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDIndexDiaryCollectionViewCell.h"

@interface WDIndexDiaryCollectionViewCell()

#pragma mark - Properties

@property(nonatomic, strong) UILabel  *wordLabel;

#pragma mark - Methods

- (void)createAndAddWordLabelWithText:(NSString *)text fontFamily:(NSString *)font size:(CGFloat)sizeFont andColor:(UIColor *)color;

@end

@implementation WDIndexDiaryCollectionViewCell

@synthesize dayDiaryLabel                       = dayDiaryLabel_;
@synthesize dateLabel                           = dateLabel_;
@synthesize wordContainerView = inicialCharacterOfWordContainerView_;
@synthesize wordLabel                           = wordLabel_;

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

#pragma mark - Auxiliary - Actions

- (void)createAndAddWordLabelWithText:(NSString *)text fontFamily:(NSString *)font size:(CGFloat)sizeFont andColor:(UIColor *)color
{
    self.wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, self.wordContainerView.bounds.size.width - 10.0, self.wordContainerView.bounds.size.height)];
    self.wordLabel.autoresizingMask = self.wordContainerView.autoresizingMask;
    self.wordLabel.attributedText = [[NSAttributedString alloc] initWithString:text
                                                               attributes:@{
                                                      NSFontAttributeName: [UIFont fontWithName:font size:sizeFont],
                                           NSForegroundColorAttributeName: color,
                                                      NSKernAttributeName: [NSNumber numberWithInt:0.5]}];
    self.wordLabel.textAlignment = NSTextAlignmentCenter;
    self.wordLabel.backgroundColor = [UIColor clearColor];
    self.wordLabel.adjustsFontSizeToFitWidth = YES;
    self.wordLabel.alpha = 1.0;
    
    [self.wordContainerView addSubview:self.wordLabel];
}


#pragma mark - Actions

- (void)showInitialLetterOfWord:(NSString *)word fontFamily:(NSString *)font andColor:(UIColor *)color
{
    [self hideWord];
    
    if (word.length > 0) {
        [self createAndAddWordLabelWithText:[word substringToIndex:1] fontFamily:font size:42.0 andColor:color];
        [UIView animateWithDuration:1 animations:^{
            self.wordLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)showAllLettersOfWord:(NSString *)word fontFamily:(NSString *)font andColor:(UIColor *)color
{
    [self hideWord];
    
    [self createAndAddWordLabelWithText:word fontFamily:font size:42.0 andColor:color];
}

- (void)hideWord
{
    [self.wordLabel removeFromSuperview];
    self.wordLabel = nil;
}


@end
