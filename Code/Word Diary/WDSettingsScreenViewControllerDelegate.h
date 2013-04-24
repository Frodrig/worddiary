//
//  WDSettingsScreenViewControllerDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 24/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSettingsScreenViewController;

@protocol WDSettingsScreenViewControllerDelegate <NSObject>

- (void) settingsScreenViewControllerWillDismiss:(WDSettingsScreenViewController *)settingsScreenViewController;
- (void) settingsScreenViewControllerDidDismiss:(WDSettingsScreenViewController *)settingsScreenViewController;

- (void) wordWithIndex:(NSArray *)index removedFromSettingsScreenViewControllerRemoveAllEmptyWordDays:(WDSettingsScreenViewController *)settingsScreenViewController;

- (void) backgroundAnimationGradientSettingsUpdateFromSettingsScreenViewController:(WDSettingsScreenViewController *)settingsScreenViewController;

@end
