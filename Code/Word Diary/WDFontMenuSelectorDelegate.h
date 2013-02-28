//
//  WDFontMenuSelectorDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDFont;

@protocol WDFontMenuSelectorDelegate <NSObject>

- (void)fontMenuSelector:(id)fontMenuObject selectedFont:(WDFont *)font;

@end
