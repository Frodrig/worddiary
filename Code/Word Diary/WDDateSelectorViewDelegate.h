//
//  WDDateSelectorViewDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDDateSelectorView;

@protocol WDDateSelectorViewDelegate <NSObject>

- (void) cancelButtonPressedFromDateSelectorView:(WDDateSelectorView *)dateSelectorView;
- (void) acceptButtonPressedWithDateComponents:(NSDateComponents *)dateComponents fromDateSelectorView:(WDDateSelectorView *)dateSelectorView;

@end
