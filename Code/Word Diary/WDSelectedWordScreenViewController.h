//
//  WDSelectedWordScreenViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDEditingWordMenuDelegate.h"
#import "WDFontMenuSelectorDelegate.h"
#import "WDColorMenuSelectorDelegate.h"

@class WDWord;

@interface WDSelectedWordScreenViewController : UIViewController<WDEditingWordMenuDelegate, WDFontMenuSelectorDelegate, WDColorMenuSelectorDelegate, UITextFieldDelegate>

- (id)initWithSelectedWord:(WDWord *)selectedWord;

@end
