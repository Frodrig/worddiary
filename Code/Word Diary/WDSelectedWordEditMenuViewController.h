//
//  WDSelectedWordEditMenuViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDSelectedWordEditMenuDelegate.h"

@interface WDSelectedWordEditMenuViewController : UIViewController

@property (nonatomic, strong) id<WDSelectedWordEditMenuDelegate> delegate;

- (void) showTodayWordMenuWithClearButtonEnabled:(BOOL)enabled;
- (void) showPreviousWordMenu;
- (void) showDeletePreviousWordConfirmationMenu;

@end
