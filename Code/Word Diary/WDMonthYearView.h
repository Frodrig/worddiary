//
//  WDMonthYearView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDMonthYearView : UIView

@property(nonatomic) BOOL drawContentDot;
@property(nonatomic) BOOL accesible;

- (id) initWithFrame:(CGRect)frame andLabel:(NSString *)label;


@end
