//
//  WDEditingWordMenuDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDEditingWordMenuDelegate <NSObject>

- (void) keyboardOptionSelectedFromMenu:(id)menu;
- (void) changeFontOptionSelectedFromMenu:(id)menu;
- (void) changeColorOptionSelectedFromMenu:(id)menu;
- (void) removeWordsOptionSelectedFromMenu:(id)menu;
- (void) exitToAllWordsScreenOptionSelected:(id)menu;

@end
