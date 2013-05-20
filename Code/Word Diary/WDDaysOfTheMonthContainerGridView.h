//
//  WDDaysOfTheMonthContainerGridView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/05/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GM_MONTH_CALENDAR,
    GM_YEAR_CALENDAR
} GridMode;

@interface WDDaysOfTheMonthContainerGridView : UIView

@property(nonatomic) GridMode mode;

@end
