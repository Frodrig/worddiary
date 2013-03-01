//
//  WDColorMenuSelectorDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 01/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDColor;

@protocol WDColorMenuSelectorDelegate <NSObject>

- (void)colorMenuSelector:(id)colorMenuObject selectedColor:(WDColor *)color;

@end
