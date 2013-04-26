//
//  WDDayMonthView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDDayMonthView : UIView

@property (nonatomic, readonly )NSUInteger index;
@property (nonatomic) NSUInteger           dayOfTheActualMonthIndex;
@property (nonatomic, strong) UILabel      *dayOfMonthLabel;
@property (nonatomic, strong) UILabel      *initialLetterLabel;
@property (nonatomic) BOOL                 removeMode;


- (id)initWithIndex:(NSUInteger)index andFrame:(CGRect)frame;

@end
