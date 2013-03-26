//
//  WDSelectedWordEditMenuViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDSelectedWordEditMenuDelegate.h"
#import "WDCollectionOptionsWordMenuViewDelegate.h"
#import "WDBackgroundDefs.h"

@class WDWord;

@interface WDSelectedWordEditMenuViewController : UIViewController<WDCollectionOptionsWordMenuViewDelegate>

@property (nonatomic, weak)   WDWord                             *selectedWord;
@property (nonatomic, strong) id<WDSelectedWordEditMenuDelegate> delegate;
@property (nonatomic)         WDColorScheme                      backgroundColorScheme;

- (id)   initWithSelectedWord:(WDWord *)word;

- (void) hideMenu;
- (void) hideMenuInmediate;
- (void) showTodayWordMenu;
- (void) showPreviousWordMenu;

- (void) updateColorScheme:(WDColorScheme)newScheme;

@end
