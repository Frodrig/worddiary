//
//  WDValueSetterModuleViewControllerDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 22/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDValueSetterModuleViewController;

@protocol WDValueSetterModuleViewControllerDelegate <NSObject>

- (void)dataValueButtonPressedForValueSetterModuleViewController:(WDValueSetterModuleViewController *)valueSetterModuleViewController;

@end
