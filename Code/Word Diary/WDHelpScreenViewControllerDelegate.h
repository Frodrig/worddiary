//
//  WDHelpScreenViewControllerDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 25/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDHelpScreenViewController;

@protocol WDHelpScreenViewControllerDelegate <NSObject>

- (void) willReachLastPageFromHelpScreenViewController:(WDHelpScreenViewController *)helpScreenViewController;
- (void) reachLastPageFromHelpScreenViewController:(WDHelpScreenViewController *)helpScreenViewController;

@end
