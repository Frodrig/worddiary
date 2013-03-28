//
//  WDAuxiliaryScreenViewControllerDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDAuxiliaryScreenViewController;

@protocol WDAuxiliaryScreenViewControllerDelegate <NSObject>

- (void)auxiliaryScreenViewBackButtonPressed:(WDAuxiliaryScreenViewController *)auxiliaryViewController;

- (void)auxiliaryAboutScreenViewWordDiaryURLPressedAndOpen:(WDAuxiliaryScreenViewController *)auxiliaryViewController;
- (void)auxiliaryAboutScreenViewDeveloperTwitterURLPressedAndOpen:(WDAuxiliaryScreenViewController *)auxiliaryViewController;

- (void)auxiliarySupportScreenViewEmailPressedAndOpen:(WDAuxiliaryScreenViewController *)auxiliaryViewController;
- (void)auxiliarySupportScreenViewEmailWasSend:(WDAuxiliaryScreenViewController *)auxiliaryViewController;

- (void)auxiliaryScreenViewWillHide:(WDAuxiliaryScreenViewController *)auxiliaryViewController;

@end
