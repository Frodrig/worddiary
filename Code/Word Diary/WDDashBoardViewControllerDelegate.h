//
//  WDDashBoardViewControllerDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDDashBoardViewController;
@class WDWord;

@protocol WDDashBoardViewControllerDelegate <NSObject>

- (void) dashBoardViewController:(WDDashBoardViewController *)dashBoardViewController createdNewWord:(WDWord *)word;

- (void) dashBoardViewController:(WDDashBoardViewController *)dashBoardViewController willDismissWithSelectedWord:(WDWord *)word;
- (void) dashBoardViewController:(WDDashBoardViewController *)dashBoardViewController selectRemoveWord:(WDWord *)word;

- (void) dashBoardViewControllerDidDismiss:(WDDashBoardViewController *)dashBoardViewController;

- (void) removeSectionsWithEmptyWordsFromDashBoardViewController:(WDDashBoardViewController *)dashBoardViewController;
- (void) backgroundAnimationGradientSettingsUpdateFromDashBoardViewController:(WDDashBoardViewController *)dashBoardViewController;



@end
