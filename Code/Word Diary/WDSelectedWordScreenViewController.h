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
#import "WDWordRepresentationViewDelegate.h"
#import "WDWordRepresentationViewDataSource.h"
#import "WDDayCheckerDelegate.h"

@class WDWord;

@interface WDSelectedWordScreenViewController : UIViewController<WDSelectedWordEditMenuDelegate, UIGestureRecognizerDelegate, WDWordRepresentationViewDataSource, WDWordRepresentationViewDelegate, WDDayCheckerDelegate>

@property (nonatomic, weak) id<WDSelectedWordScreenDelegate> delegate;

- (id)init;

- (void)resign;
- (void)didEnterBackground;
- (void)willEnterForeground;
- (void)didBecomeActive;
- (void)terminate;

@end
