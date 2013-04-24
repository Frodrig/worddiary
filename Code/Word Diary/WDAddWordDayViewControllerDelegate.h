//
//  WDAddWordDayViewControllerDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 24/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWord;
@class WDAddWordDayViewController;

@protocol WDAddWordDayViewControllerDelegate <NSObject>

- (void) addWordDayViewController:(WDAddWordDayViewController *)addWordDayViewController createdNewWord:(WDWord *)word;
- (void) addWordDayViewController:(WDAddWordDayViewController *)addWordDayViewController willDismissWithSelectedWord:(WDWord *)word;

@end
