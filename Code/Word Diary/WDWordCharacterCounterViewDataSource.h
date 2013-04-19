//
//  WDWordCharacterCounterViewDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 18/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDWordCharacterCounterView;

@protocol WDWordCharacterCounterViewDataSource <NSObject>

- (NSUInteger) numberOfFreeCharactersOfEditWordForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView;
- (UIColor *)  colorForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView;

@end
