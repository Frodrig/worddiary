//
//  WDSelectedWordScreenViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDSelectedWordEditMenuDelegate.h"
#import "WDSelectedWordScreenDelegate.h"

@class WDWord;

@interface WDSelectedWordScreenViewController : UIViewController<WDSelectedWordEditMenuDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id<WDSelectedWordScreenDelegate> delegate;

- (id)initWithSelectedWord:(WDWord *)selectedWord;

@end
