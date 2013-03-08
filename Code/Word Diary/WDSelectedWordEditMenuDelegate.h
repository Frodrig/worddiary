//
//  WDSelectedWordEditMenuDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDSelectedWordEditMenuDelegate <NSObject>

- (void)writeSelectedWordOption;
- (void)clearTodaySelectedWordOption;
- (void)cancelDeleteWordFromConfirmationMenu;
- (void)acceptDeleteWordFromConfirmationMenu;

@end
